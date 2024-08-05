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

create table Locations (
    id serial primary key,
    active boolean,
    name varchar(50) not null unique,
    phone varchar(15),
    address_1 varchar(128),
    address_2 varchar(32),
    city varchar(35),
    state varchar(2),
    zip_code varchar(15),
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int,
    updated_user_id int
);

create table Patients (
    id serial primary key,
    active boolean,
    first_name varchar(50),
    middle_name varchar(50),
    last_name varchar(50),
    date_of_birth date null,
    date_of_death date null,
    email varchar(99),
    phone varchar(15),
    password varchar(60) null,
    address_1 varchar(128),
    address_2 varchar(32),
    city varchar(35),
    state varchar(2),
    zip_code varchar(15),
    notes varchar(2500),
    can_call boolean not null,
    can_text boolean not null,
    can_email boolean not null,
    location_id int not null,
    user_id int not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int,
    updated_user_id int
);

create table RecentPatients (
    user_id int not null references Users(id),
    patient_id int not null references Patients(id),
    date_created timestamp not null,
    unique(user_id, patient_id)
);

create table Avatars (
    type VARCHAR(20) NOT NULL,
    entity_id INTEGER NOT NULL,
    image BYTEA,
    PRIMARY KEY (type, entity_id),
    CONSTRAINT fk_user_avatar FOREIGN KEY (entity_id) REFERENCES Users(id) ON DELETE CASCADE,
    CONSTRAINT fk_patient_avatar FOREIGN KEY (entity_id) REFERENCES Patients(id) ON DELETE CASCADE
);