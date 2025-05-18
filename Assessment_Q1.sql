USE adashi_staging;

# checking all the tables out for necessary information and columns
SELECT *
FROM plans_plan;

SELECT *
FROM savings_savingsaccount;

SELECT *
FROM users_customuser;

# the name column is null so it is populated by merging both first and last name columns

ALTER TABLE users_customuser DROP COLUMN name;

ALTER TABLE users_customuser ADD COLUMN name VARCHAR(50);

UPDATE users_customuser
SET name = CONCAT(first_name,' ',last_name);

# the list of only current users is filtered out from the users table and only columns to solve the question were select

SELECT id, email, name, account_source, is_account_deleted
FROM users_customuser
WHERE is_account_deleted != 1;

# a temporary table was created for this so it can be easily called

CREATE TEMPORARY TABLE current_users
SELECT id, name, email, account_source, is_active
FROM users_customuser
WHERE is_account_deleted != 1;

# the table is checked
SELECT * FROM current_users;

# temporary tables were also created for users with investment plansa and savings plan respectively

CREATE TEMPORARY TABLE investment_list
SELECT id, name, amount, owner_id,
is_a_fund
FROM plans_plan
WHERE is_a_fund = 1;

CREATE TEMPORARY TABLE savings_list
SELECT id, name, amount, owner_id,
is_regular_savings
FROM plans_plan
WHERE is_regular_savings = 1;

# both tables were checked
SELECT * FROM investment_list;

SELECT * FROM savings_list;

# the count of savings for each unique customer was determined from this list and temporary tables were created from them likewise

CREATE TEMPORARY TABLE savings_per_user
SELECT SUM(amount) AS savings,
COUNT(is_regular_savings) AS savings_count,
owner_id
FROM savings_list
GROUP BY owner_id
ORDER BY savings_count DESC;

CREATE TEMPORARY TABLE investment_per_user
SELECT SUM(amount) AS investments,
COUNT(is_a_fund) AS investment_count,
owner_id
FROM investment_list
GROUP BY owner_id
ORDER BY investment_count DESC;

# Deduce the total deposi made by each user from the savings table and create a temporary table for this too

SELECT SUM(ROUND(confirmed_amount)) AS total_deposits,owner_id
FROM savings_savingsaccount
GROUP BY owner_id
ORDER BY SUM(confirmed_amount);

CREATE TEMPORARY TABLE total_deposits
SELECT SUM(confirmed_amount) AS total_deposits,owner_id
FROM savings_savingsaccount
GROUP BY owner_id
ORDER BY SUM(confirmed_amount);

# use the inner join to merge all the tables together with the users tables the primary table

SELECT *
FROM current_users u
INNER JOIN total_deposits td
	ON u.id = td.owner_id
INNER JOIN savings_per_user s
	ON u.id = s.owner_id
INNER JOIN investment_per_user iv
	ON u.id = iv.owner_id;
    
# filter out a few columns and format  the answer in a much cleaner 
SELECT id AS owner_id, 
name,
savings_count,
investment_count,
ROUND(total_deposits,0) AS total_deposits
FROM current_users u
INNER JOIN total_deposits td
	ON u.id = td.owner_id
INNER JOIN savings_per_user s
	ON u.id = s.owner_id
INNER JOIN investment_per_user iv
	ON u.id = iv.owner_id
ORDER BY total_deposits;


