create table Bro (
    id serial primary key,
    active boolean not null,
    name varchar(16) not null,
    password varchar(60) not null,
    color int not null,
    sees_clients boolean not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int
);

create table Location (
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
    created_bro_id int,
    updated_bro_id int
);

create table Schedule (
    location_id int not null,
    bro_id int, -- if null, it's the location's hours of operation
    hours_sun_from time not null,
    hours_sun_to time not null,
    hours_mon_from time not null,
    hours_mon_to time not null,
    hours_tue_from time not null,
    hours_tue_to time not null,
    hours_wed_from time not null,
    hours_wed_to time not null,
    hours_thu_from time not null,
    hours_thu_to time not null,
    hours_fri_from time not null,
    hours_fri_to time not null,
    hours_sat_from time not null,
    hours_sat_to time not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int,
    unique nulls not distinct(location_id, bro_id)
);

create table Client (
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
    location_id int not null references location(id),
    bro_id int not null references Bro(id),
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int
);



create table AppointmentType (
    id serial primary key,
    active boolean not null,
    name varchar(32) not null,
    color int not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int
);

create table AppointmentStatus (
    id serial primary key,
    active boolean not null,
    name varchar(32) not null,
    visible boolean not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int
);

create table Appointment (
    id serial primary key,
    title varchar(16),
    appt_date date not null,
    appt_from time not null,
    appt_to time not null,
    notes varchar(2500),
    client_id int references Client(id),
    type_id int references AppointmentType(id),
    status_id int references AppointmentStatus(id),
    location_id int not null references Location(id),
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int
);

create table Appointment_Bro (
    appointment_id int not null references Appointment(id),
    bro_id int not null references Bro(id),
    unique(appointment_id, bro_id)
);