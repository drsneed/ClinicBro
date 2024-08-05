-- Enable the pgcrypto extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO Users (active, name, password, color, is_provider, date_created, date_updated, created_user_id, updated_user_id)
VALUES
    (true, 'Alexander', crypt('alexander', gen_salt('bf')), '#003366', true, NOW(), NOW(), NULL, NULL),
    (true, 'Benjamin', crypt('benjamin', gen_salt('bf')), '#4B0082', false, NOW(), NOW(), NULL, NULL),
    (true, 'Catherine', crypt('catherine', gen_salt('bf')), '#008080', true, NOW(), NOW(), NULL, NULL),
    (true, 'Dorothy', crypt('dorothy', gen_salt('bf')), '#800080', true, NOW(), NOW(), NULL, NULL),
    (true, 'Edward', crypt('edward', gen_salt('bf')), '#4682B4', false, NOW(), NOW(), NULL, NULL),
    (true, 'Fiona', crypt('fiona', gen_salt('bf')), '#008000', true, NOW(), NOW(), NULL, NULL),
    (true, 'George', crypt('george', gen_salt('bf')), '#A52A2A', true, NOW(), NOW(), NULL, NULL),
    (true, 'Helen', crypt('helen', gen_salt('bf')), '#D2B48C', false, NOW(), NOW(), NULL, NULL),
    (true, 'Isaac', crypt('isaac', gen_salt('bf')), '#DC143C', true, NOW(), NOW(), NULL, NULL),
    (true, 'Julian', crypt('julian', gen_salt('bf')), '#20B2AA', false, NOW(), NOW(), NULL, NULL);


INSERT INTO Patients (active, first_name, middle_name, last_name, date_of_birth, email, phone, address_1, city, state, zip_code, notes, can_call, can_text, can_email, location_id, user_id, date_created, date_updated, created_user_id, updated_user_id)
VALUES
    (true, 'John', 'Michael', 'Doe', '1985-03-15', 'john.doe@email.com', '555-0101', '123 Main St', 'Springfield', 'IL', '62701', 'Regular check-ups', true, true, true, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (true, 'Jane', 'Elizabeth', 'Smith', '1990-07-22', 'jane.smith@email.com', '555-0102', '456 Elm St', 'Shelbyville', 'IL', '62565', 'Allergic to penicillin', true, false, true, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (false, 'Robert', 'James', 'Johnson', '1978-11-30', 'robert.johnson@email.com', '555-0103', '789 Oak Ave', 'Capital City', 'IL', '62701', 'Transferred to another clinic', false, false, false, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2, 2),
    (true, 'Emily', 'Grace', 'Brown', '1995-09-08', 'emily.brown@email.com', '555-0104', '321 Pine Rd', 'Springfield', 'IL', '62702', 'Pregnant - due date 2023-12-15', true, true, true, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (true, 'Michael', 'Thomas', 'Davis', '1982-05-17', 'michael.davis@email.com', '555-0105', '654 Cedar Ln', 'Shelbyville', 'IL', '62565', 'Diabetic', true, true, false, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2, 2),
    (true, 'Sarah', 'Anne', 'Wilson', '1988-12-03', 'sarah.wilson@email.com', '555-0106', '987 Birch St', 'Capital City', 'IL', '62701', 'Asthma', false, true, true, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (true, 'David', 'Lee', 'Taylor', '1975-02-28', 'david.taylor@email.com', '555-0107', '147 Maple Dr', 'Springfield', 'IL', '62703', 'High blood pressure', true, false, true, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2, 2),
    (true, 'Jennifer', 'Marie', 'Anderson', '1992-08-11', 'jennifer.anderson@email.com', '555-0108', '258 Walnut Ave', 'Shelbyville', 'IL', '62565', 'Vegetarian diet', true, true, true, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (false, 'Christopher', 'Alan', 'Thomas', '1980-06-20', 'christopher.thomas@email.com', '555-0109', '369 Spruce Ct', 'Capital City', 'IL', '62701', 'Moved out of state', false, false, false, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2, 2),
    (true, 'Jessica', 'Lynn', 'Jackson', '1993-04-05', 'jessica.jackson@email.com', '555-0110', '741 Ash St', 'Springfield', 'IL', '62704', 'Lactose intolerant', true, true, false, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (true, 'Daniel', 'Joseph', 'White', '1987-10-14', 'daniel.white@email.com', '555-0111', '852 Hickory Ln', 'Shelbyville', 'IL', '62565', 'Regular physical therapy', false, true, true, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2, 2),
    (true, 'Michelle', 'Nicole', 'Harris', '1991-01-25', 'michelle.harris@email.com', '555-0112', '963 Sycamore Rd', 'Capital City', 'IL', '62701', 'Allergic to latex', true, false, true, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1);


INSERT INTO Patients (
    active, first_name, middle_name, last_name, date_of_birth, date_of_death, email, phone, password, address_1, address_2, city, state, zip_code, notes, can_call, can_text, can_email, location_id, user_id, date_created, date_updated, created_user_id, updated_user_id
) VALUES
(TRUE, 'Liam', 'X.', 'Murphy', '1985-07-21', NULL, 'liam.murphy@example.com', '555-1234-567', NULL, '789 Oak St', 'Suite 300', 'Pittsburgh', 'PA', '15201', 'No allergies', TRUE, TRUE, TRUE, 1, 6, now(), now(), 6, 6),
(TRUE, 'Olivia', 'Y.', 'Clark', '1992-11-13', NULL, 'olivia.clark@example.com', '555-5678-123', NULL, '456 Pine St', 'Apt 12B', 'Seattle', 'WA', '98101', 'Prefers email contact', TRUE, FALSE, TRUE, 1, 7, now(), now(), 7, 7),
(TRUE, 'Noah', 'Z.', 'Gonzalez', '1978-03-09', NULL, 'noah.gonzalez@example.com', '555-8765-432', NULL, '321 Elm St', NULL, 'Austin', 'TX', '73301', 'Diabetic', TRUE, TRUE, FALSE, 1, 8, now(), now(), 8, 8),
(TRUE, 'Emma', 'A.', 'Martinez', '1989-06-22', NULL, 'emma.martinez@example.com', '555-4321-876', NULL, '654 Maple St', 'Unit 3', 'San Diego', 'CA', '92101', 'No specific notes', TRUE, TRUE, TRUE, 1, 9, now(), now(), 9, 9),
(TRUE, 'Ethan', 'B.', 'Rodriguez', '1981-04-15', NULL, 'ethan.rodriguez@example.com', '555-3456-789', NULL, '987 Cedar St', NULL, 'Chicago', 'IL', '60601', 'Allergic to penicillin', TRUE, TRUE, FALSE, 1, 10, now(), now(), 10, 10),
(TRUE, 'Ava', 'C.', 'Lewis', '1995-09-30', NULL, 'ava.lewis@example.com', '555-2345-678', NULL, '321 Birch St', 'Apt 5A', 'New York', 'NY', '10001', 'Prefers text communication', TRUE, TRUE, TRUE, 1, 11, now(), now(), 11, 11),
(TRUE, 'Mason', 'D.', 'Walker', '1980-01-19', NULL, 'mason.walker@example.com', '555-6789-012', NULL, '123 Spruce St', NULL, 'Los Angeles', 'CA', '90001', 'No special notes', TRUE, FALSE, TRUE, 1, 12, now(), now(), 12, 12),
(TRUE, 'Isabella', 'E.', 'Young', '1990-12-11', NULL, 'isabella.young@example.com', '555-7890-123', NULL, '456 Fir St', 'Suite 2', 'Denver', 'CO', '80201', 'Asthmatic', TRUE, TRUE, TRUE, 1, 13, now(), now(), 13, 13),
(TRUE, 'Jacob', 'F.', 'King', '1975-08-08', NULL, 'jacob.king@example.com', '555-8901-234', NULL, '789 Fir St', 'Apt 1', 'Philadelphia', 'PA', '19101', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 14, now(), now(), 14, 14),
(TRUE, 'Sophia', 'G.', 'Scott', '1988-02-14', NULL, 'sophia.scott@example.com', '555-9012-345', NULL, '654 Oak St', NULL, 'San Francisco', 'CA', '94101', 'Pregnant', TRUE, TRUE, TRUE, 1, 15, now(), now(), 15, 15),
(TRUE, 'Jackson', 'H.', 'Adams', '1993-10-24', NULL, 'jackson.adams@example.com', '555-1234-678', NULL, '321 Maple St', 'Unit 7', 'Miami', 'FL', '33101', 'No special notes', TRUE, TRUE, TRUE, 1, 6, now(), now(), 6, 6),
(TRUE, 'Mia', 'I.', 'Baker', '1987-07-30', NULL, 'mia.baker@example.com', '555-2345-789', NULL, '123 Oak St', 'Apt 9B', 'Houston', 'TX', '77001', 'Prefers call contact', TRUE, TRUE, FALSE, 1, 7, now(), now(), 7, 7),
(TRUE, 'James', 'J.', 'Mitchell', '1983-05-17', NULL, 'james.mitchell@example.com', '555-3456-890', NULL, '456 Cedar St', NULL, 'San Antonio', 'TX', '78201', 'No allergies', TRUE, TRUE, TRUE, 1, 8, now(), now(), 8, 8),
(TRUE, 'Charlotte', 'K.', 'Carter', '1991-01-02', NULL, 'charlotte.carter@example.com', '555-4567-901', NULL, '789 Elm St', 'Suite 101', 'Phoenix', 'AZ', '85001', 'Prefers email contact', TRUE, TRUE, TRUE, 1, 9, now(), now(), 9, 9),
(TRUE, 'Oliver', 'L.', 'Nelson', '1984-11-25', NULL, 'oliver.nelson@example.com', '555-5678-012', NULL, '654 Pine St', NULL, 'Dallas', 'TX', '75201', 'Diabetic', TRUE, TRUE, TRUE, 1, 10, now(), now(), 10, 10),
(TRUE, 'Amelia', 'M.', 'Morris', '1996-09-18', NULL, 'amelia.morris@example.com', '555-6789-123', NULL, '321 Maple St', 'Apt 4C', 'San Diego', 'CA', '92101', 'No specific notes', TRUE, TRUE, TRUE, 1, 11, now(), now(), 11, 11),
(TRUE, 'Benjamin', 'N.', 'Bailey', '1982-06-12', NULL, 'benjamin.bailey@example.com', '555-7890-234', NULL, '123 Birch St', 'Unit 2', 'San Jose', 'CA', '95101', 'No allergies', TRUE, TRUE, TRUE, 1, 12, now(), now(), 12, 12),
(TRUE, 'Evelyn', 'O.', 'Harris', '1989-12-30', NULL, 'evelyn.harris@example.com', '555-8901-345', NULL, '456 Fir St', NULL, 'Austin', 'TX', '73301', 'Prefers text communication', TRUE, TRUE, FALSE, 1, 13, now(), now(), 13, 13),
(TRUE, 'Henry', 'P.', 'Young', '1994-08-21', NULL, 'henry.young@example.com', '555-9012-456', NULL, '789 Oak St', 'Apt 8D', 'Jacksonville', 'FL', '32201', 'Asthmatic', TRUE, TRUE, TRUE, 1, 14, now(), now(), 14, 14),
(TRUE, 'Avery', 'Q.', 'Wright', '1986-04-10', NULL, 'avery.wright@example.com', '555-0123-456', NULL, '123 Pine St', 'Unit 10', 'San Francisco', 'CA', '94101', 'No special notes', TRUE, TRUE, TRUE, 1, 15, now(), now(), 15, 15),
(TRUE, 'William', 'R.', 'Turner', '1979-02-05', NULL, 'william.turner@example.com', '555-1234-567', NULL, '654 Elm St', NULL, 'Columbus', 'OH', '43201', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 6, now(), now(), 6, 6),
(TRUE, 'Harper', 'S.', 'Collins', '1992-07-14', NULL, 'harper.collins@example.com', '555-2345-678', NULL, '321 Cedar St', 'Apt 5E', 'Charlotte', 'NC', '28201', 'Pregnant', TRUE, TRUE, TRUE, 1, 7, now(), now(), 7, 7),
(TRUE, 'Elijah', 'T.', 'Foster', '1987-11-09', NULL, 'elijah.foster@example.com', '555-3456-789', NULL, '456 Oak St', NULL, 'San Antonio', 'TX', '78201', 'Diabetic', TRUE, TRUE, TRUE, 1, 8, now(), now(), 8, 8),
(TRUE, 'Ella', 'U.', 'Graham', '1991-05-25', NULL, 'ella.graham@example.com', '555-4567-890', NULL, '789 Maple St', 'Suite 202', 'Indianapolis', 'IN', '46201', 'Prefers call contact', TRUE, TRUE, FALSE, 1, 9, now(), now(), 9, 9),
(TRUE, 'Lucas', 'V.', 'Wright', '1980-12-13', NULL, 'lucas.wright@example.com', '555-5678-901', NULL, '123 Birch St', 'Apt 7C', 'San Diego', 'CA', '92101', 'Asthmatic', TRUE, TRUE, TRUE, 1, 10, now(), now(), 10, 10),
(TRUE, 'Mia', 'W.', 'Simmons', '1993-04-02', NULL, 'mia.simmons@example.com', '555-6789-012', NULL, '456 Fir St', NULL, 'Kansas City', 'MO', '64101', 'No specific notes', TRUE, TRUE, TRUE, 1, 11, now(), now(), 11, 11),
(TRUE, 'James', 'X.', 'Reed', '1985-10-17', NULL, 'james.reed@example.com', '555-7890-123', NULL, '789 Pine St', 'Unit 4', 'Las Vegas', 'NV', '89101', 'No allergies', TRUE, TRUE, TRUE, 1, 12, now(), now(), 12, 12),
(TRUE, 'Grace', 'Y.', 'Morris', '1998-06-05', NULL, 'grace.morris@example.com', '555-8901-234', NULL, '123 Oak St', 'Apt 3B', 'Milwaukee', 'WI', '53201', 'Prefers email contact', TRUE, TRUE, TRUE, 1, 13, now(), now(), 13, 13),
(TRUE, 'Alexander', 'Z.', 'Kim', '1982-08-29', NULL, 'alexander.kim@example.com', '555-9012-345', NULL, '456 Maple St', NULL, 'Atlanta', 'GA', '30301', 'No special notes', TRUE, TRUE, TRUE, 1, 14, now(), now(), 14, 14),
(TRUE, 'Chloe', 'A.', 'Bell', '1995-03-16', NULL, 'chloe.bell@example.com', '555-0123-456', NULL, '789 Elm St', 'Suite 5', 'Virginia Beach', 'VA', '23450', 'Diabetic', TRUE, TRUE, TRUE, 1, 15, now(), now(), 15, 15),
(TRUE, 'Daniel', 'B.', 'Parker', '1983-01-22', NULL, 'daniel.parker@example.com', '555-1234-567', NULL, '321 Birch St', NULL, 'Omaha', 'NE', '68101', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 6, now(), now(), 6, 6),
(TRUE, 'Lily', 'C.', 'Sanders', '1990-11-07', NULL, 'lily.sanders@example.com', '555-2345-678', NULL, '654 Cedar St', 'Apt 2B', 'Honolulu', 'HI', '96801', 'Prefers call contact', TRUE, TRUE, TRUE, 1, 7, now(), now(), 7, 7),
(TRUE, 'Matthew', 'D.', 'Cole', '1976-09-15', NULL, 'matthew.cole@example.com', '555-3456-789', NULL, '789 Fir St', NULL, 'Tucson', 'AZ', '85701', 'Asthmatic', TRUE, TRUE, TRUE, 1, 8, now(), now(), 8, 8),
(TRUE, 'Aubrey', 'E.', 'Butler', '1989-06-01', NULL, 'aubrey.butler@example.com', '555-4567-890', NULL, '123 Pine St', 'Suite 10', 'Minneapolis', 'MN', '55401', 'No special notes', TRUE, TRUE, TRUE, 1, 9, now(), now(), 9, 9),
(TRUE, 'Ryan', 'F.', 'Gray', '1984-02-19', NULL, 'ryan.gray@example.com', '555-5678-901', NULL, '456 Oak St', 'Apt 5D', 'Cincinnati', 'OH', '45201', 'Pregnant', TRUE, TRUE, TRUE, 1, 10, now(), now(), 10, 10),
(TRUE, 'Zoe', 'G.', 'Bennett', '1993-07-08', NULL, 'zoe.bennett@example.com', '555-6789-012', NULL, '789 Maple St', 'Unit 4', 'St. Louis', 'MO', '63101', 'No allergies', TRUE, TRUE, TRUE, 1, 11, now(), now(), 11, 11),
(TRUE, 'Elijah', 'H.', 'Mitchell', '1981-10-20', NULL, 'elijah.mitchell@example.com', '555-7890-123', NULL, '321 Birch St', NULL, 'Pittsburgh', 'PA', '15201', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 12, now(), now(), 12, 12),
(TRUE, 'Aria', 'I.', 'Cox', '1996-05-14', NULL, 'aria.cox@example.com', '555-8901-234', NULL, '654 Fir St', 'Apt 9B', 'Raleigh', 'NC', '27601', 'Prefers text communication', TRUE, TRUE, TRUE, 1, 13, now(), now(), 13, 13),
(TRUE, 'Jacob', 'J.', 'Fisher', '1984-12-28', NULL, 'jacob.fisher@example.com', '555-9012-345', NULL, '789 Oak St', 'Suite 3', 'Kansas City', 'MO', '64101', 'Diabetic', TRUE, TRUE, TRUE, 1, 14, now(), now(), 14, 14),
(TRUE, 'Emily', 'K.', 'Cooper', '1992-08-09', NULL, 'emily.cooper@example.com', '555-0123-456', NULL, '123 Cedar St', 'Unit 8B', 'Atlanta', 'GA', '30301', 'No special notes', TRUE, TRUE, TRUE, 1, 15, now(), now(), 15, 15),
(TRUE, 'Aiden', 'L.', 'Price', '1988-03-26', NULL, 'aiden.price@example.com', '555-1234-567', NULL, '456 Maple St', 'Apt 3A', 'Salt Lake City', 'UT', '84101', 'No allergies', TRUE, TRUE, TRUE, 1, 6, now(), now(), 6, 6),
(TRUE, 'Nora', 'M.', 'Reynolds', '1994-10-14', NULL, 'nora.reynolds@example.com', '555-2345-678', NULL, '789 Fir St', 'Suite 5D', 'Tampa', 'FL', '33601', 'Asthmatic', TRUE, TRUE, TRUE, 1, 7, now(), now(), 7, 7),
(TRUE, 'Michael', 'N.', 'Young', '1979-07-18', NULL, 'michael.young@example.com', '555-3456-789', NULL, '123 Birch St', NULL, 'Orlando', 'FL', '32801', 'Prefers call contact', TRUE, TRUE, TRUE, 1, 8, now(), now(), 8, 8),
(TRUE, 'Luna', 'O.', 'Ward', '1997-09-23', NULL, 'luna.ward@example.com', '555-4567-890', NULL, '456 Pine St', 'Apt 2A', 'Columbus', 'OH', '43201', 'Diabetic', TRUE, TRUE, TRUE, 1, 9, now(), now(), 9, 9),
(TRUE, 'Jack', 'P.', 'Watson', '1991-05-30', NULL, 'jack.watson@example.com', '555-5678-901', NULL, '789 Oak St', 'Unit 6B', 'Charlotte', 'NC', '28201', 'No special notes', TRUE, TRUE, TRUE, 1, 10, now(), now(), 10, 10),
(TRUE, 'Maya', 'Q.', 'Fisher', '1986-01-19', NULL, 'maya.fisher@example.com', '555-6789-012', NULL, '321 Maple St', 'Apt 10C', 'San Antonio', 'TX', '78201', 'Pregnant', TRUE, TRUE, TRUE, 1, 11, now(), now(), 11, 11),
(TRUE, 'Owen', 'R.', 'Butler', '1990-11-25', NULL, 'owen.butler@example.com', '555-7890-123', NULL, '654 Fir St', NULL, 'San Diego', 'CA', '92101', 'Asthmatic', TRUE, TRUE, TRUE, 1, 12, now(), now(), 12, 12),
(TRUE, 'Eleanor', 'S.', 'Diaz', '1983-03-19', NULL, 'eleanor.diaz@example.com', '555-8901-234', NULL, '123 Oak St', 'Apt 4A', 'Indianapolis', 'IN', '46201', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 13, now(), now(), 13, 13),
(TRUE, 'Daniel', 'T.', 'Mitchell', '1982-12-01', NULL, 'daniel.mitchell@example.com', '555-9012-345', NULL, '456 Pine St', 'Suite 2', 'San Francisco', 'CA', '94101', 'No allergies', TRUE, TRUE, TRUE, 1, 14, now(), now(), 14, 14),
(TRUE, 'Charlotte', 'U.', 'Murphy', '1994-09-10', NULL, 'charlotte.murphy@example.com', '555-0123-456', NULL, '789 Cedar St', 'Apt 3B', 'Denver', 'CO', '80201', 'Prefers text communication', TRUE, TRUE, TRUE, 1, 15, now(), now(), 15, 15),
(TRUE, 'Michael', 'V.', 'Perry', '1980-10-20', NULL, 'michael.perry@example.com', '555-1234-567', NULL, '123 Pine St', 'Suite 8', 'Phoenix', 'AZ', '85001', 'Diabetic', TRUE, TRUE, TRUE, 1, 6, now(), now(), 6, 6),
(TRUE, 'Harper', 'W.', 'Morgan', '1987-07-11', NULL, 'harper.morgan@example.com', '555-2345-678', NULL, '456 Oak St', 'Unit 2A', 'Houston', 'TX', '77001', 'Pregnant', TRUE, TRUE, TRUE, 1, 7, now(), now(), 7, 7),
(TRUE, 'James', 'X.', 'Martin', '1995-03-22', NULL, 'james.martin@example.com', '555-3456-789', NULL, '789 Maple St', 'Apt 6C', 'Chicago', 'IL', '60601', 'No allergies', TRUE, TRUE, TRUE, 1, 8, now(), now(), 8, 8),
(TRUE, 'Avery', 'Y.', 'Cooper', '1989-06-30', NULL, 'avery.cooper@example.com', '555-4567-890', NULL, '321 Cedar St', 'Suite 101', 'San Diego', 'CA', '92101', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 9, now(), now(), 9, 9),
(TRUE, 'Liam', 'Z.', 'Parker', '1991-12-14', NULL, 'liam.parker@example.com', '555-5678-901', NULL, '654 Fir St', 'Apt 4A', 'Los Angeles', 'CA', '90001', 'No special notes', TRUE, TRUE, TRUE, 1, 10, now(), now(), 10, 10),
(TRUE, 'Sophia', 'A.', 'Watson', '1996-04-08', NULL, 'sophia.watson@example.com', '555-6789-012', NULL, '789 Oak St', 'Unit 5B', 'San Francisco', 'CA', '94101', 'Asthmatic', TRUE, TRUE, TRUE, 1, 11, now(), now(), 11, 11),
(TRUE, 'Jackson', 'B.', 'Rivera', '1984-02-20', NULL, 'jackson.rivera@example.com', '555-7890-123', NULL, '123 Pine St', 'Apt 7A', 'Dallas', 'TX', '75201', 'No specific notes', TRUE, TRUE, TRUE, 1, 12, now(), now(), 12, 12),
(TRUE, 'Zoe', 'C.', 'Jenkins', '1991-05-18', NULL, 'zoe.jenkins@example.com', '555-8901-234', NULL, '456 Cedar St', 'Suite 5', 'Philadelphia', 'PA', '19101', 'Diabetic', TRUE, TRUE, TRUE, 1, 13, now(), now(), 13, 13),
(TRUE, 'Michael', 'D.', 'Long', '1986-08-22', NULL, 'michael.long@example.com', '555-9012-345', NULL, '789 Fir St', 'Apt 2C', 'San Jose', 'CA', '95101', 'Pregnant', TRUE, TRUE, TRUE, 1, 14, now(), now(), 14, 14),
(TRUE, 'Mia', 'E.', 'Bryant', '1983-01-15', NULL, 'mia.bryant@example.com', '555-0123-456', NULL, '123 Oak St', 'Unit 9A', 'Minneapolis', 'MN', '55401', 'Hearing impairment', TRUE, TRUE, FALSE, 1, 15, now(), now(), 15, 15);


INSERT INTO locations (
    active, name, phone, address_1, address_2, city, state, zip_code, date_created, date_updated, created_user_id, updated_user_id
) VALUES 
(true, 'Headquarters', '555-000-1111', '123 Corporate Plaza', 'Floor 10', 'Metropolis', 'NY', '10001', NOW(), NOW(), 10, 10),
(true, 'Tech Hub', '555-222-3333', '456 Innovation Dr', NULL, 'Techville', 'CA', '94105', NOW(), NOW(), 10, 10),
(true, 'Customer Service Center', '555-444-5555', '789 Service Ln', 'Suite A', 'Servicetown', 'TX', '75201', NOW(), NOW(), 10, 10),
(false, 'Closed Branch', '555-666-7777', '321 Pastel Ave', NULL, 'Old City', 'FL', '33130', NOW(), NOW(), 10, 10),
(true, 'Logistics Center', '555-888-9999', '654 Logistics Blvd', 'Warehouse 5', 'Transport Town', 'IL', '60616', NOW(), NOW(), 10, 10);
