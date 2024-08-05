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