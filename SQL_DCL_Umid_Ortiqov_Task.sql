--1.Create a new user
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';

-- Grant the user the ability to connect to the database
ALTER USER rentaluser WITH LOGIN;

-- Optionally, you can restrict the user from creating new databases
ALTER USER rentaluser WITH NOCREATEDB;


-- 2.Grant SELECT permission on the "customer" table to the "rentaluser" user
GRANT SELECT ON TABLE customer TO rentaluser;

-- Select all customers from the "customer" table
SELECT * FROM customer;


-- 3.Create a new user group called "rental"
CREATE GROUP rental;

-- Add the user "rentaluser" to the "rental" group
ALTER GROUP rental ADD USER rentaluser;


-- 4.Grant INSERT and UPDATE permissions on the "rental" table to the "rental" group
GRANT INSERT, UPDATE ON TABLE rental TO rental;

-- Insert a new row into the "rental" table
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES ('2023-11-27', 123, 600, '2023-12-05', 2, CURRENT_TIMESTAMP);

-- Update an existing row in the "rental" table
UPDATE rental
SET return_date = '2023-12-10'
WHERE rental_id = 1;


-- 5.Revoke INSERT permission on the "rental" table from the "rental" group
REVOKE INSERT ON TABLE rental FROM rental;

-- Attempt to insert a new row into the "rental" table (this should be denied)
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES ('2023-11-27', 123, 456, '2023-12-05', 789, CURRENT_TIMESTAMP);



-- 6.Check if the sample customer already exists if not create it.
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM customer WHERE first_name = 'John' AND last_name = 'Doe') THEN
    INSERT INTO customer (store_id, first_name, last_name, email, address_id, activebool, create_date, last_update, active)
    VALUES (1, 'John', 'Doe', 'john.doe@example.com', 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, true);
  END IF;
END $$;

-- Get the customer_id for the newly created or existing customer
DO $$ 
BEGIN 
  PERFORM setval('customer_customer_id_seq', (SELECT customer_id FROM customer WHERE first_name = 'John' AND last_name = 'Doe'), true);
END $$;

-- Create a personalized role for the customer
CREATE ROLE client_John_Doe;

-- Grant SELECT permission on "rental" and "payment" tables to the personalized role
GRANT SELECT ON TABLE rental TO client_John_Doe;
GRANT SELECT ON TABLE payment TO client_John_Doe;

-- Grant USAGE on the sequences to obtain IDs for new records
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO client_John_Doe;

-- Grant access to their own data only
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO client_John_Doe;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO client_John_Doe;

-- Query their own data from the "rental" table
SELECT * FROM rental WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'John' AND last_name = 'Doe');

-- Query their own data from the "payment" table
SELECT * FROM payment WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'John' AND last_name = 'Doe');
