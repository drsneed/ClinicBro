-- Enable the pgcrypto extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Insert seed data into Users table
INSERT INTO Users (active, name, password, color, sees_patients, date_created, date_updated, created_user_id, updated_user_id)
VALUES
    (true, 'John Doe', crypt('password123', gen_salt('bf')), '#FF5733', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL, NULL),
    (true, 'Jane Smith', crypt('securepass', gen_salt('bf')), '#33FF57', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1),
    (false, 'Bob Johnson', crypt('bobspassword', gen_salt('bf')), '#3357FF', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 2),
    (true, 'Alice Williams', crypt('alicepass123', gen_salt('bf')), '#FF33F1', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2, 2),
    (true, 'Charlie Brown', crypt('snoopy', gen_salt('bf')), '#33FFF1', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1);

-- Insert seed data into Avatar table
INSERT INTO Avatar (user_id, image)
VALUES
    (1, E'\\x89504E470D0A1A0A0000000D4948445200000100000001000100000000'),
    (2, E'\\x89504E470D0A1A0A0000000D4948445200000100000001000100000001'),
    (4, E'\\x89504E470D0A1A0A0000000D4948445200000100000001000100000002');