USE adashi_staging;

# get familiar with the needed tables and possible columns to work with

SELECT *
FROM plans_plan;

SELECT *
FROM savings_savingsaccount;

# filtering out all active accounts i.e accounts with either an investment or savings plan

SELECT id, name, start_date,is_a_fund,
is_regular_savings
FROM plans_plan
WHERE is_a_fund = 1 OR is_regular_savings = 1;

# clean up the table by inputing the data with investment and savings

SELECT id, name, start_date,is_a_fund,
is_regular_savings,
owner_id, REPLACE(REPLACE(is_a_fund,1, 'Investments'), 0, ' ') AS ty, REPLACE(REPLACE(is_regular_savings,1,'Savings'), 0, ' ') AS pe
FROM plans_plan
WHERE is_a_fund = 1 OR is_regular_savings = 1;

# merge both columns together as one and trim out extra spaces

SELECT id,
name,
owner_id,
start_date,
TRIM(CONCAT(ty,pe)) AS type
FROM (
SELECT id, name, start_date,is_a_fund,
is_regular_savings,
owner_id, REPLACE(REPLACE(is_a_fund,1, 'Investments'), 0, ' ') AS ty, REPLACE(REPLACE(is_regular_savings,1,'Savings'), 0, ' ') AS pe
FROM plans_plan
WHERE is_a_fund = 1 OR is_regular_savings = 1
) AS active 
;

# create a temporary table for this query for its easy access and retrieval. The table is for all active users with either a savings or investment plan

CREATE TEMPORARY TABLE active_table
SELECT id,
name,
owner_id,
start_date,
TRIM(CONCAT(ty,pe)) AS type
FROM (
SELECT id, name, start_date,is_a_fund,
is_regular_savings,
owner_id, REPLACE(REPLACE(is_a_fund,1, 'Investments'), 0, ' ') AS ty, REPLACE(REPLACE(is_regular_savings,1,'Savings'), 0, ' ') AS pe
FROM plans_plan
WHERE is_a_fund = 1 OR is_regular_savings = 1
) AS active 
;

# determine the number of distinct plan for the savings table 

SELECT COUNT(DISTINCT(plan_id))
FROM savings_savingsaccount;

# retrieve all the rows with last transaction made filtering it out by plan and owner

SELECT plan_id,
owner_id,
MAX(transaction_date) AS last_transaction_date
FROM savings_savingsaccount 
GROUP BY 1,2
ORDER BY 1,2;

# use a subquery to select transactions that has been more than a year
SELECT plan_id,
owner_id,
last_transaction_date
FROM (
SELECT  plan_id,
owner_id,
MAX(transaction_date) AS last_transaction_date
FROM savings_savingsaccount
GROUP BY 1,2
ORDER BY 1,2
) AS transactions
WHERE last_transaction_date < NOW() - INTERVAL 1 YEAR;


# create a temporary table for all transactions that are more than a year
CREATE TEMPORARY TABLE inactive_transactions
SELECT plan_id,
owner_id,
last_transaction_date
FROM (
SELECT  plan_id,
owner_id,
MAX(transaction_date) AS last_transaction_date
FROM savings_savingsaccount
GROUP BY 1,2
ORDER BY 1,2
) AS transactions
WHERE last_transaction_date < NOW() - INTERVAL 1 YEAR;

# calculate the number of inactive days by substracting 365 for the difference between the last transaction and current date

SELECT *,
DATEDIFF(NOW(), last_transaction_date) -365 AS inactivity_days
FROM inactive_transactions;
# create another table for this
CREATE TEMPORARY TABLE inactive_days
SELECT *,
DATEDIFF(NOW(), last_transaction_date) -365 AS inactivity_days
FROM inactive_transactions;
# checking out both tables to determine if al needed information is present
SELECT * FROM active_table;
SELECT * FROM inactive_days;

# recover every information from both tables using the primary keys and foreigns key contraint when necessary  to see transactions with null type( no investment or savings) i.e inactive as well as active users with null transactions

SELECT *
FROM active_table a
LEFT JOIN inactive_days id
	ON a.id = id.plan_id 
    AND a.owner_id = id.owner_id
;

# perform a inner join to find all active users with no transactions in the last 365 days
SELECT id.plan_id,
a.owner_id,
type,
last_transaction_date,
inactivity_days
FROM active_table a
INNER JOIN inactive_days id
	ON a.id = id.plan_id 
    AND a.owner_id = id.owner_id
;
