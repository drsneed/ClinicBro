create table users (
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

create table locations (
    id serial primary key,
    active boolean,
    name varchar(50) not null,
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


create table operating_schedule (
    location_id int not null,
    user_id int, -- if null, it's the location's hours of operation
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
    created_user_id int,
    updated_user_id int,
    unique nulls not distinct(location_id, user_id)
);

create table patients (
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
    provider_id int not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int,
    updated_user_id int
);

create table recent_patients (
    user_id int not null references Users(id),
    patient_id int not null references Patients(id),
    date_created timestamp not null,
    unique(user_id, patient_id)
);

create table avatars (
    type VARCHAR(20) NOT NULL,
    entity_id INTEGER NOT NULL,
    image BYTEA,
    PRIMARY KEY (type, entity_id),
    CONSTRAINT fk_user_avatar FOREIGN KEY (entity_id) REFERENCES Users(id) ON DELETE CASCADE,
    CONSTRAINT fk_patient_avatar FOREIGN KEY (entity_id) REFERENCES Patients(id) ON DELETE CASCADE
);

create table appointment_types (
    id serial primary key,
    active boolean not null,
    name varchar(32) not null,
    description varchar(256) null,
    color varchar(9) not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int,
    updated_user_id int
);

create table appointment_statuses (
    id serial primary key,
    active boolean not null,
    name varchar(32) not null,
    description varchar(256) null,
    show boolean not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int,
    updated_user_id int
);

create table appointments (
    id serial primary key,
    title varchar(16) not null,
    appt_date date not null,
    appt_from time not null,
    appt_to time not null,
    notes varchar(2500) not null,
    patient_id int not null,
    provider_id int not null,
    appointment_type_id int not null,
    appointment_status_id int not null,
    location_id int not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int not null,
    updated_user_id int not null
);

create view appointment_items as 
  select a.id as appt_id,
  case when appt_type is not null then appt_type.name else a.title end as title,
  case when appt_status is null then 'New' else appt_status.name end as status,
  case when pat is null then '' else concat(pat.last_name, ', ', pat.first_name) end as patient,
  case when prov is null then '' else prov.name end as provider,
  case when loc is null then '' else loc.name end as location,
  case when appt_type is null then '' else appt_type.color end as color,
  to_char(a.appt_date, 'YYYY-MM-DD') as appt_date, 
  to_char(a.appt_from, 'HH24:MI') as appt_from, 
  to_char(a.appt_to, 'HH24:MI') as appt_to
  from appointments a 
  left join patients pat on pat.id=a.patient_id
  left join users prov on prov.id=a.provider_id
  left join locations loc on loc.id=a.location_id
  left join appointment_types appt_type on appt_type.id=a.appointment_type_id
  left join appointment_statuses appt_status on appt_status.id=a.appointment_status_id
  order by a.appt_date, a.appt_from;
