from fastapi import FastAPI, HTTPException, Depends, Header, Response, UploadFile, File
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import FileResponse
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from os import getenv
from typing import Optional, List
from dotenv import load_dotenv
import jwt
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()
DB_CONNECTION_STRING = getenv("DATABASE_URL")
if DB_CONNECTION_STRING is None:
    raise Exception("Missing DB Connection string")

# JWT settings
SECRET_KEY = getenv("JWT_SECRET_KEY")
if not SECRET_KEY:
    raise Exception("JWT_SECRET_KEY not set in environment variables")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Create an async SQLAlchemy engine
engine = create_async_engine(DB_CONNECTION_STRING, echo=True)
async_session = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

# Define the request body models
class AuthRequest(BaseModel):
    name: str
    password: str

class UserCreate(BaseModel):
    name: str
    password: str
    color: str
    is_provider: bool
    active: bool = True

class UserUpdate(BaseModel):
    name: Optional[str] = None
    password: Optional[str] = None
    color: Optional[str] = None
    is_provider: Optional[bool] = None
    active: Optional[bool] = None

class UserResponse(BaseModel):
    id: int
    name: str
    color: str
    is_provider: bool
    active: bool
    date_created: datetime
    date_updated: datetime

app = FastAPI()

def create_jwt_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@app.post("/authenticate")
async def authenticate(auth_request: AuthRequest):
    async with async_session() as session:
        async with session.begin():
            query = text("""
                SELECT * FROM Users
                WHERE name = :name
                  AND active = true
                  AND (password = crypt(:password, password))
            """)
            # print('auth_request.name: ' + auth_request.name)
            # print('\nauth_request.password: ' + auth_request.password)
            result = await session.execute(query, {
                'name': auth_request.name,
                'password': auth_request.password
            })
            user = result.fetchone()
            if user:
                token_data = {"sub": auth_request.name, "user_id": user.id}
                token = create_jwt_token(token_data)
                return {"token": token, "user_id": user.id}
            else:
                raise HTTPException(status_code=401, detail="Invalid user or password")

security = HTTPBearer()

async def validate_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# Create a new user
@app.post("/users", response_model=UserResponse)
async def create_user(user: UserCreate, token: dict = Depends(validate_token)):
    async with async_session() as session:
        async with session.begin():
            query = text("""
                INSERT INTO Users (name, password, color, is_provider, active, date_created, date_updated, created_user_id, updated_user_id)
                VALUES (:name, crypt(:password, gen_salt('bf')), :color, :is_provider, :active, NOW(), NOW(), :user_id, :user_id)
                RETURNING id, name, color, is_provider, active, date_created, date_updated
            """)
            result = await session.execute(query, {
                'name': user.name,
                'password': user.password,
                'color': user.color,
                'is_provider': user.is_provider,
                'active': user.active,
                'user_id': token['user_id']
            })
            new_user = result.fetchone()
            return UserResponse(**dict(new_user))

# Get a user by ID
@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, token: dict = Depends(validate_token)):
    async with async_session() as session:
        async with session.begin():
            query = text("""
                SELECT id, name, color, is_provider, active, date_created, date_updated
                FROM Users
                WHERE id = :user_id
            """)
            result = await session.execute(query, {'user_id': user_id})
            user = result.fetchone()
            if user:
                return UserResponse(**{column: value for column, value in zip(result.keys(), user)})
            else:
                raise HTTPException(status_code=404, detail="User not found")

# Get all users
@app.get("/users", response_model=List[UserResponse])
async def get_all_users(token: dict = Depends(validate_token)):
    async with async_session() as session:
        async with session.begin():
            query = text("""
                SELECT id, name, color, is_provider, active, date_created, date_updated
                FROM Users
            """)
            result = await session.execute(query)
            users = result.fetchall()
            return [UserResponse(**{column: value for column, value in zip(result.keys(), user)}) for user in users]
        
# Create a new avatar
@app.post("/avatar")
async def create_avatar(user_id: int, file: UploadFile = File(...), token: dict = Depends(validate_token)):
    image_data = await file.read()
    async with async_session() as session:
        async with session.begin():
            query = text("""
                INSERT INTO Avatar (user_id, image) 
                VALUES (:user_id, :image)
                ON CONFLICT (user_id) 
                DO UPDATE SET image = EXCLUDED.image
            """)
            await session.execute(query, {'user_id': user_id, 'image': image_data})
            return {"message": "Avatar created/updated successfully"}

# Get user avatar
@app.get("/avatar/{user_id}")
async def get_avatar(user_id: int, token: dict = Depends(validate_token)):
    async with async_session() as session:
        async with session.begin():
            query = text("""
                SELECT image FROM Avatar 
                WHERE user_id = :user_id
            """)
            result = await session.execute(query, {'user_id': user_id})
            avatar = result.scalar()
            
            if avatar:
                return Response(content=avatar, media_type="image/png")
            else:
                return FileResponse("img/avatar.png")

# Update avatar
@app.put("/avatar/{user_id}")
async def update_avatar(user_id: int, file: UploadFile = File(...), token: dict = Depends(validate_token)):
    image_data = await file.read()
    async with async_session() as session:
        async with session.begin():
            query = text("""
                UPDATE Avatar
                SET image = :image
                WHERE user_id = :user_id
            """)
            result = await session.execute(query, {'user_id': user_id, 'image': image_data})
            if result.rowcount == 0:
                raise HTTPException(status_code=404, detail="Avatar not found")
            return {"message": "Avatar updated successfully"}

# Delete avatar
@app.delete("/avatar/{user_id}")
async def delete_avatar(user_id: int, token: dict = Depends(validate_token)):
    async with async_session() as session:
        async with session.begin():
            query = text("""
                DELETE FROM Avatar 
                WHERE user_id = :user_id
            """)
            result = await session.execute(query, {'user_id': user_id})
            if result.rowcount == 0:
                raise HTTPException(status_code=404, detail="Avatar not found")
            return {"message": "Avatar deleted successfully"}

# Example of another protected endpoint
@app.get("/protected-endpoint")
async def protected_endpoint(token: dict = Depends(validate_token)):
    return {"message": "This is a protected endpoint", "user": token["sub"]}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.1.34", port=33420)
