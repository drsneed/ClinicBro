CREATE table user_account (
    id SERIAL PRIMARY KEY,
    name VARCHAR(16) UNIQUE, 
    password VARCHAR(60) NOT NULL,
    date_created TIMESTAMP NOT NULL);
    
INSERT INTO user_account(name, password, date_created) values('Dustin', crypt('drsneed', gen_salt('bf')), NOW());
INSERT INTO user_account(name, password, date_created) values('CEO Bob', crypt('ceo', gen_salt('bf')), NOW());
INSERT INTO user_account(name, password, date_created) values('Randy', crypt('randy', gen_salt('bf')), NOW());

    SELECT (password = crypt('drsneed', password)) AS correct_password FROM user_account where name='Dustin'