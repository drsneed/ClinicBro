INSERT INTO Bro(active, name, password, color, sees_clients, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Admin', crypt('admin', gen_salt('bf')), 0, false, NOW(), NOW(), 0, 0);

INSERT INTO Bro(active, name, password, color, sees_clients, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Dustin', crypt('drsneed', gen_salt('bf')), 0, true, NOW(), NOW(), 0, 0);

INSERT INTO Bro(active, name, password, color, sees_clients, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Rupert', crypt('rupert', gen_salt('bf')), 0, false, NOW(), NOW(), 0, 0);

--------------------------------------------

INSERT INTO Client(active,first_name,middle_name,last_name,date_of_birth,date_of_death,email,phone,password,address_1,address_2,city,state,zip,notes,can_call,can_text,can_email,bro_id, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true,'John','Leonard','McNugget','1971-09-30',NULL,'john@coal.br','(307) 464-9001',null,'225 Wright Blvd',NULL,'Wright','WY','82718',NULL,true,true,true,(select id from Bro where name='Dustin'),NOW(), NOW(), 0, 0);

----------------------------------------

INSERT INTO AppointmentType(active, name, color, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Exam', 0, NOW(), NOW(), 0, 0);
INSERT INTO AppointmentType(active, name, color, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Consult', 0, NOW(), NOW(), 0, 0);


----------------------------------------

INSERT INTO AppointmentStatus(active, name, visible, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Created', true, NOW(), NOW(), 0, 0);
INSERT INTO AppointmentStatus(active, name, visible, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Confirmed', true, NOW(), NOW(), 0, 0);
INSERT INTO AppointmentStatus(active, name, visible, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Attended', true, NOW(), NOW(), 0, 0);
INSERT INTO AppointmentStatus(active, name, visible, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Rescheduled', true, NOW(), NOW(), 0, 0);
INSERT INTO AppointmentStatus(active, name, visible, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'Cancelled', false, NOW(), NOW(), 0, 0);
INSERT INTO AppointmentStatus(active, name, visible, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(true, 'No Show', false, NOW(), NOW(), 0, 0);

-----------------------------------------------------

INSERT INTO Appointment(title,appt_date,appt_from,appt_to,notes,client_id,type_id,status_id, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES('Staff Meeting','2024-06-27','10:00:00','10:30:00','Bring your water bottles!',NULL,NULL,(select id from AppointmentStatus where name='Created'),NOW(), NOW(), 0, 0);

INSERT INTO Appointment(title,appt_date,appt_from,appt_to,notes,client_id,type_id,status_id, date_created, date_updated, created_bro_id, updated_bro_id)
VALUES(null,'2024-06-28','13:00:00','13:30:00',NULL,(select id from Client),
    (select id from AppointmentType where name='Exam'),(select id from AppointmentStatus where name='Created'),NOW(), NOW(), 0, 0);

INSERT INTO Appointment_Bro(appointment_id, bro_id) VALUES((select id from Appointment where title='Staff Meeting'), (select id from Bro where name='Admin'));
INSERT INTO Appointment_Bro(appointment_id, bro_id) VALUES((select id from Appointment where title='Staff Meeting'), (select id from Bro where name='Dustin'));
INSERT INTO Appointment_Bro(appointment_id, bro_id) VALUES((select id from Appointment where title='Staff Meeting'), (select id from Bro where name='Rupert'));

INSERT INTO Appointment_Bro(appointment_id, bro_id) VALUES((select id from Appointment where title is NULL), (select id from Bro where name='Dustin'));
