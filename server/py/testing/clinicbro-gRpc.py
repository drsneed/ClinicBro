import grpc
from concurrent import futures
import auth_pb2
import auth_pb2_grpc
import asyncpg
from sqlalchemy import create_engine, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
import asyncio

DATABASE_URL = "postgresql+asyncpg://postgres:tokyo_2@localhost/ClinicBro"

# Create an async SQLAlchemy engine
engine = create_async_engine(DATABASE_URL, echo=True)
async_session = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

class AuthService(auth_pb2_grpc.AuthServiceServicer):
    async def Authenticate(self, request: auth_pb2.AuthRequest, context: grpc.ServicerContext) -> auth_pb2.AuthResponse:
        async with async_session() as session:
            async with session.begin():
                # Define the query
                query = text("""
                    SELECT * FROM Bro
                    WHERE name = :name
                      AND active = true
                      AND (password = crypt(:password, password))
                """)

                # Execute the query
                result = await session.execute(query, {
                    'name': request.name,
                    'password': request.password
                })

                user = result.fetchone()

                if user:
                    return auth_pb2.AuthResponse(token="blippity bloop")
                else:
                    context.set_details("Invalid user or password")
                    context.set_code(grpc.StatusCode.UNAUTHENTICATED)
                    return auth_pb2.AuthResponse()

async def serve():
    server = grpc.aio.server()
    auth_pb2_grpc.add_AuthServiceServicer_to_server(AuthService(), server)
    server.add_insecure_port('192.168.1.34:33420')
    await server.start()
    await server.wait_for_termination()

if __name__ == '__main__':
    asyncio.run(serve())
