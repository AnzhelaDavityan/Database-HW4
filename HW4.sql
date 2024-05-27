CREATE TABLE Address (
    address_id SERIAL PRIMARY KEY,
    city VARCHAR(190),
    street VARCHAR(250),
    apt_No INTEGER
);

CREATE TYPE account_type AS ENUM ('guest', 'user', 'moderator', 'administrator');
CREATE TABLE table_User (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(254) UNIQUE CHECK (email ~ '^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$'),
    full_name VARCHAR(200) NOT NULL,
    address_id SERIAL REFERENCES Address(address_id),
	birthday DATE,
	last_login DATE,
	biography TEXT DEFAULT 'Tell us about yourself',
	two_factor_auth_enabled BOOLEAN DEFAULT FALSE,
	account_type account_type
);

CREATE TABLE Phone(
  	user_id SERIAL,
  	phone_number VARCHAR(12) PRIMARY KEY,
  	FOREIGN KEY (user_id) REFERENCES table_User(user_id)
	
);

CREATE TYPE skill_type AS ENUM ('ANALYTICAL', 'CREATIVE', 'COMMUNICATION', 'TECHNICAL','LEADERSHIP');
CREATE TABLE Skill (
	skill_id SERIAL PRIMARY KEY,
	skill_name VARCHAR(250) NOT NULL,
	skill_type skill_type,
	skill_description TEXT
);

CREATE TYPE society_status AS ENUM ('active', 'Lower class', 'middle class', 'upper class');
CREATE TABLE Society (
    society_id SERIAL PRIMARY KEY,
    society_name VARCHAR(300) NOT NULL,
    society_status society_status,
    society_description TEXT
);

CREATE TABLE UserSkills (
    skill_id SERIAL REFERENCES Skill(skill_id),
	user_id SERIAL REFERENCES table_User(user_id),
    PRIMARY KEY (user_id, skill_id),
	proficiency REAL CHECK (proficiency >= 1.0 AND proficiency <= 10.0)
);

CREATE TABLE SocietyUser (
    society_id SERIAL REFERENCES Society(society_id),
	user_id SERIAL REFERENCES table_User(user_id),
    PRIMARY KEY (society_id, user_id),
	registration_date DATE NOT NULL,
	expiration_date DATE NOT NULL
);

CREATE TYPE job_type AS ENUM ('full-time', 'part-time', 'contract', 'intern');
CREATE TYPE post_type AS ENUM ('common', 'top', 'urgent');
CREATE TABLE PostedJobs (
    skill_id SERIAL REFERENCES Skill(skill_id),
	user_id SERIAL REFERENCES table_User(user_id),
	society_id SERIAL REFERENCES Society(society_id),
	PRIMARY KEY (skill_id, user_id,society_id),
    job_title VARCHAR(300) NOT NULL,
	job_description TEXT NOT NULL,
	job_type job_type,
	post_type post_type,
	post_date DATE NOT NULL,
	expiration_date DATE NOT NULL
);

/*exercise 2 */
INSERT INTO Address (city, street, apt_No) VALUES
('Yerevan', 'Abovyan Street', 125),
('New York', 'Fifth Avenue', 202),
('Los Angeles', 'Sunset Boulevard', 303),
('San Francisco', 'Market Street', 101)
;
SELECT * FROM Address;

INSERT INTO table_User (email, full_name, birthday, last_login, biography, two_factor_auth_enabled, account_type) VALUES
('john.doe@example.com', 'John Doe','1980-01-01', '2023-03-10', 'Software developer.', FALSE, 'user'),
('jane.smith@example.com', 'Jane Smith','1985-02-02', '2023-03-09', 'Project manager.', TRUE, 'moderator'),
('alex.johnson@example.com', 'Alex Johnson','1990-03-03', NULL, DEFAULT, FALSE, 'guest'),
('joe.smith@example.com', 'Joe Smith','1984-05-01', '2022-03-10', 'Software developer.', TRUE, 'user')
;
SELECT * FROM table_User;

INSERT INTO Phone (phone_number) VALUES
('096-454590'),
('099-567890'),
('098-678490'),
('098-878890');
SELECT * FROM Phone;

INSERT INTO Skill (skill_name, skill_type, skill_description) VALUES
('PostgreSQL', 'ANALYTICAL', 'Ability to analyze data and extract meaningful insights.'),
('Graphic Design', 'CREATIVE', 'Expertise in visual communication and problem-solving through the use illustration.'),
('Effective Communication', 'COMMUNICATION', 'The ability to convey information to others effectively and efficiently.'),
('PostgreSQL', 'ANALYTICAL', 'The ability to solve problems');
SELECT * FROM Skill;

INSERT INTO Society (society_name, society_status, society_description) VALUES
('Tech Club', 'active', 'A community of innovators.'),
('Artists Guild', 'middle class', 'A collective of artists'),
('Leadership Circle', 'upper class', 'An elite group of leaders focused on shaping the future of their industries.'),
('Tech Club', 'middle class', 'A group of people focused on shaping the future');
SELECT * FROM Society;

INSERT INTO UserSkills(proficiency) VALUES
(9.5),
(8.0),
(7.5),
(5.5);
SELECT * FROM UserSkills;

INSERT INTO SocietyUser (registration_date, expiration_date) VALUES
('2023-01-01', '2024-01-01'),
('2023-02-01', '2024-02-01'),
('2023-03-01', '2024-03-01'),
('2023-04-01', '2024-04-01');
SELECT * FROM SocietyUser;

INSERT INTO PostedJobs (job_title, job_description, job_type, post_type, post_date, expiration_date) VALUES
('Software Developer', 'Develop and maintain software applications.', 'full-time', 'common', '2023-03-01', '2023-09-01'),
('Graphic Designer', 'Create visual concepts to communicate ideas.', 'part-time', 'top', '2023-04-01', '2023-10-01'),
('Project Manager', 'Lead project teams to achieve milestones and objectives.', 'contract', 'urgent', '2023-05-01', '2023-11-01'),
('3D Expert', '3D modeling is the funniest job', 'contract', 'urgent', '2023-06-05', '2023-09-01');
SELECT * FROM PostedJobs;

/* Problem 1-3*/

SELECT 
    U1.full_name AS User1, 
    U2.full_name AS User2, 
    A_1.city 
FROM 
    table_User AS U1
JOIN 
    Address AS A_1 ON U1.address_id = A_1.address_id
JOIN 
    table_User AS U2 ON U1.user_id < U2.user_id
JOIN 
    Address AS A_2 ON U2.address_id = A_2.address_id AND A_1.city = A_2.city
ORDER BY 
    A_1.city, U1.full_name, U2.full_name;

/* Problem 1-4*/
SELECT
    U.full_name,
    U.email,
    A.city
FROM
    table_User AS U
INNER JOIN
    Address AS A ON U.address_id = A.address_id
WHERE
    A.city = 'Yerevan';

/* Problem 1-5*/
SELECT
    PJ.job_title
FROM
    PostedJobs AS PJ
JOIN
    Society AS S ON PJ.society_id = S.society_id
JOIN
    Skill AS SK ON PJ.skill_id = SK.skill_id
WHERE
    S.society_name = 'Tech Club'
    AND SK.skill_name = 'PostgreSQL';


DROP TABLE IF EXISTS PostedJobs;
DROP TABLE IF EXISTS SocietyUser;
DROP TABLE IF EXISTS UserSkills;
DROP TABLE IF EXISTS Phone;
DROP TABLE IF EXISTS table_User;
DROP TABLE IF EXISTS Skill;
DROP TABLE IF EXISTS Society;
DROP TABLE IF EXISTS Address;

DROP TYPE IF EXISTS post_type;
DROP TYPE IF EXISTS job_type;
DROP TYPE IF EXISTS society_status;
DROP TYPE IF EXISTS skill_type;
DROP TYPE IF EXISTS account_type;


/*Problem 2*/
DROP TABLE IF EXISTS giftcard;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS single_rental;
DROP TABLE IF EXISTS table_subscription;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS movie;

CREATE TABLE movie (
    movie_id INT PRIMARY KEY,
    title VARCHAR(64) NOT NULL,
    release_year INT NOT NULL,
    genre VARCHAR(64) NOT NULL,
    editor_rating INT NOT NULL
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(64) NOT NULL,
    last_name VARCHAR(64) NOT NULL,
    join_date DATE NOT NULL,
    country VARCHAR(64) NOT NULL
);

CREATE TABLE table_subscription (
    subscription_id INT PRIMARY KEY,
    length_is INT NOT NULL,
    start_date DATE NOT NULL,
    platform VARCHAR(32) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(8,2) NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE single_rental (
    single_rental_id INT PRIMARY KEY,
    rental_date DATE NOT NULL,
    rental_period INT NOT NULL,
    platform VARCHAR(64) NOT NULL,
    customer_id INT NOT NULL,
    movie_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(8,2) NOT NULL,
	FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE review (
    review_id INT PRIMARY KEY,
    rating INT NOT NULL,
    customer_id INT NOT NULL,
    movie_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id)
);

CREATE TABLE giftcard (
    giftcard_id INT PRIMARY KEY,
    amount_worth INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(8,2) NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

COPY customer
FROM '/Users/anzheladavityan/Desktop/HW4/customer-table.csv'
WITH(FORMAT csv,HEADER true);

COPY giftcard
FROM '/Users/anzheladavityan/Desktop/HW4/giftcard-table.csv'
WITH(FORMAT csv,HEADER true);

COPY movie
FROM '/Users/anzheladavityan/Desktop/HW4/movie-table.csv'
WITH(FORMAT csv,HEADER true);

COPY review
FROM '/Users/anzheladavityan/Desktop/HW4/review-table.csv'
WITH(FORMAT csv,HEADER true);

COPY single_rental
FROM '/Users/anzheladavityan/Desktop/HW4/single-rental-table.csv'
WITH(FORMAT csv,HEADER true);

COPY table_subscription
FROM '/Users/anzheladavityan/Desktop/HW4/subscription-table.csv'
WITH(FORMAT csv,HEADER true);

SELECT * FROM movie;
SELECT * FROM customer;
SELECT * FROM table_subscription;
SELECT * FROM single_rental;
SELECT * FROM review;
SELECT * FROM giftcard;

SELECT * FROM single_rental WHERE rental_period BETWEEN 1 AND 7;


/*
SELECT usename FROM pg_user;
*/
/*Problem 2-4*/
SELECT
    subscription_id,
    length_is AS length,
    start_date,
    payment_amount,
    SUM(payment_amount) OVER (ORDER BY start_date ASC) AS running_total
FROM
    table_subscription
ORDER BY
    start_date ASC;
	
/*Problem 2-5*/
SELECT
    title,
    editor_rating,
    genre,
    AVG(editor_rating) OVER (PARTITION BY genre) AS avg_genre_editor_rating
FROM
    movie
ORDER BY
	title,genre;

/*Problem 2-6*/
SELECT DISTINCT
    m.title,
    AVG(r.rating) OVER (PARTITION BY m.movie_id) AS avg_movie_rating,
    AVG(r.rating) OVER (PARTITION BY m.genre) AS avg_genre_rating,
    AVG(r.rating) OVER () AS avg_rating
FROM
    movie m
JOIN
    review r ON m.movie_id = r.movie_id
ORDER BY
	m.title;
/*Problem 2-7*/
SELECT
    sr.rental_date,
    m.title,
    m.genre,
    sr.payment_amount,
    RANK() OVER (PARTITION BY m.genre ORDER BY sr.payment_amount DESC) AS rental_rank
FROM
    single_rental AS sr
JOIN
    movie AS m ON sr.movie_id = m.movie_id
ORDER BY
    m.genre,
    rental_rank;

