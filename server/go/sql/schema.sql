create table users (
    id serial primary key,
    active boolean not null,
    name varchar(16) not null,
    password varchar(60) not null,
    color varchar(9) not null,
    is_provider boolean not null,
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


create table operating_schedules (
    location_id int not null,
    user_id int, -- if null, it's the location's hours of operation
    hours_sun_from time,
    hours_sun_to time,
    hours_mon_from time,
    hours_mon_to time,
    hours_tue_from time,
    hours_tue_to time,
    hours_wed_from time,
    hours_wed_to time,
    hours_thu_from time,
    hours_thu_to time,
    hours_fri_from time,
    hours_fri_to time,
    hours_sat_from time,
    hours_sat_to time,
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

-- Drop indexes for appointments table
DROP INDEX IF EXISTS idx_appointments_is_event;
DROP INDEX IF EXISTS idx_appointments_appt_date;
DROP INDEX IF EXISTS idx_appointments_patient_id;
DROP INDEX IF EXISTS idx_appointments_provider_id;
DROP INDEX IF EXISTS idx_appointments_location_id;
DROP INDEX IF EXISTS idx_appointments_appointment_type_id;
DROP INDEX IF EXISTS idx_appointments_appointment_status_id;
DROP INDEX IF EXISTS idx_appointments_date_created;
DROP INDEX IF EXISTS idx_appointments_date_provider;
DROP INDEX IF EXISTS idx_appointments_date_patient;
DROP INDEX IF EXISTS idx_appointments_date_location;
DROP INDEX IF EXISTS idx_appointments_date_status;

-- Drop indexes for event_user_links table
DROP INDEX IF EXISTS idx_event_user_links_appointment_id;
DROP INDEX IF EXISTS idx_event_user_links_user_id;
DROP INDEX IF EXISTS idx_event_user_links_appointment_user;

-- Drop tables
DROP TABLE IF EXISTS event_user_links;
DROP TABLE IF EXISTS appointments;

create table appointments (
    id serial primary key,
    title varchar(16),
    is_event boolean default false,
    appt_date date not null,
    appt_from time not null,
    appt_to time not null,
    notes varchar(2500) not null,
    patient_id int,
    provider_id int,
    appointment_type_id int,
    appointment_status_id int,
    location_id int not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_user_id int not null,
    updated_user_id int not null
);

CREATE INDEX idx_appointments_is_event ON appointments(is_event);

CREATE INDEX idx_appointments_appt_date ON appointments(appt_date);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_provider_id ON appointments(provider_id);
CREATE INDEX idx_appointments_location_id ON appointments(location_id);
CREATE INDEX idx_appointments_appointment_type_id ON appointments(appointment_type_id);
CREATE INDEX idx_appointments_appointment_status_id ON appointments(appointment_status_id);
CREATE INDEX idx_appointments_date_created ON appointments(date_created);

-- Composite indexes for common query patterns
CREATE INDEX idx_appointments_date_provider ON appointments(appt_date, provider_id);
CREATE INDEX idx_appointments_date_patient ON appointments(appt_date, patient_id);
CREATE INDEX idx_appointments_date_location ON appointments(appt_date, location_id);
CREATE INDEX idx_appointments_date_status ON appointments(appt_date, appointment_status_id);

CREATE TABLE event_user_links (
    id SERIAL PRIMARY KEY,
    appointment_id INT NOT NULL REFERENCES appointments(id),
    user_id INT NOT NULL REFERENCES users(id),
    UNIQUE (appointment_id, user_id)
);
CREATE INDEX idx_event_user_links_appointment_id ON event_user_links(appointment_id);
CREATE INDEX idx_event_user_links_user_id ON event_user_links(user_id);
CREATE INDEX idx_event_user_links_appointment_user ON event_user_links(appointment_id, user_id);

CREATE VIEW appointment_items AS 
SELECT 
    a.id AS appt_id,
    CASE 
        WHEN a.is_event THEN a.title 
        ELSE appt_type.name 
    END AS title,
    CASE 
        WHEN appt_status.name IS NULL THEN '' 
        ELSE appt_status.name 
    END AS status,
    CASE 
        WHEN a.is_event THEN 
            string_agg(u.name, ', ') 
        ELSE 
            '' 
    END AS participants, -- For events
    CASE 
        WHEN a.is_event THEN 
            '' 
        ELSE 
            COALESCE(concat(pat.last_name, ', ', pat.first_name), '') 
    END AS patient, -- For appointments
    CASE 
        WHEN a.is_event THEN '' 
        ELSE COALESCE(prov.name, '') 
    END AS provider,
    CASE 
        WHEN a.is_event THEN '' 
        ELSE COALESCE(loc.name, '') 
    END AS location,
    CASE 
        WHEN appt_type.color IS NULL THEN '' 
        ELSE appt_type.color 
    END AS color,
    TO_CHAR(a.appt_date, 'YYYY-MM-DD') AS appt_date, 
    TO_CHAR(a.appt_from, 'HH24:MI') AS appt_from, 
    TO_CHAR(a.appt_to, 'HH24:MI') AS appt_to,
    a.notes
FROM appointments a
LEFT JOIN patients pat ON pat.id = a.patient_id
LEFT JOIN users prov ON prov.id = a.provider_id
LEFT JOIN locations loc ON loc.id = a.location_id
LEFT JOIN appointment_types appt_type ON appt_type.id = a.appointment_type_id
LEFT JOIN appointment_statuses appt_status ON appt_status.id = a.appointment_status_id
LEFT JOIN event_user_links eul ON eul.appointment_id = a.id
LEFT JOIN users u ON u.id = eul.user_id
GROUP BY 
    a.id, a.title, a.is_event, appt_type.name, appt_status.name, pat.last_name, pat.first_name, 
    prov.name, loc.name, appt_type.color, a.appt_date, a.appt_from, a.appt_to, a.notes
ORDER BY 
    a.appt_date, a.appt_from;

