create table Users (
    id serial primary key,
    active boolean not null,
    name varchar(16) not null,
    password varchar(60) not null,
    color varchar(9) not null,
    sees_patients boolean not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int,
    updated_user_id int
);

CREATE TABLE Avatars (
    user_id INTEGER PRIMARY KEY REFERENCES Users(id) UNIQUE,
    image BYTEA
);

