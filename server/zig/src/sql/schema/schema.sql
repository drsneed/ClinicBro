create table Bro (
    id serial primary key,
    active boolean not null,
    name varchar(16) not null,
    password varchar(60) not null,
    color varchar(9) not null,
    sees_clients boolean not null,
    recent_clients int[],
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

create table RecentClient (
    bro_id int not null references Bro(id),
    client_id int not null references Client(id),
    date_created timestamp not null,
    unique(bro_id, client_id)
);

create table AppointmentType (
    id serial primary key,
    active boolean not null,
    name varchar(32) not null,
    description varchar(256) null,
    color varchar(9) not null,
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
    description varchar(256) null,
    show boolean not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int,
    updated_bro_id int
);

create table Appointment (
    id serial primary key,
    title varchar(16) not null,
    appt_date date not null,
    appt_from time not null,
    appt_to time not null,
    notes varchar(2500) not null,
    client_id int not null,
    bro_id int not null,
    type_id int not null,
    status_id int not null,
    location_id int not null,
    -- tracking columns
    date_created timestamp not null,
    date_updated timestamp not null,
    created_bro_id int not null,
    updated_bro_id int not null
);

create view AppointmentView as 
  select a.id as appt_id,
  case when appt_type is not null then appt_type.name else a.title end as title,
  case when appt_status is null then 'New' else appt_status.name end as status,
  case when cl is null then '' else concat(cl.last_name, ', ', cl.first_name) end as client,
  case when provider is null then '' else provider.name end as provider,
  case when loc is null then '' else loc.name end as location,
  case when appt_type is null then '' else appt_type.color end as color,
  to_char(a.appt_date, 'YYYY-MM-DD') as appt_date, 
  to_char(a.appt_from, 'HH24:MI') as appt_from, 
  to_char(a.appt_to, 'HH24:MI') as appt_to
  from appointment a 
  left join client cl on cl.id=a.client_id
  left join bro provider on provider.id=a.bro_id
  left join location loc on loc.id=a.location_id
  left join appointmenttype appt_type on appt_type.id=a.type_id
  left join appointmentstatus appt_status on appt_status.id=a.status_id
  order by a.appt_date, a.appt_from;


create table SystemConfig
    (x char(1) not null unique default ('X') check (x = 'X'),
    client_title varchar(32) not null default ('Client'));