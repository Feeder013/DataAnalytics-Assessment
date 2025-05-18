USE adashi_staging;

SELECT *
FROM users_customuser;

#identifying all the relevant data from both tables

CREATE TEMPORARY TABLE present_users
SELECT id,name,is_active, account_source
FROM users_customuser;

SELECT *
FROM savings_savingsaccount;

CREATE TEMPORARY TABLE transactions
SELECT savings_id,
plan_id,
transaction_date,
amount,
owner_id
FROM savings_savingsaccount
ORDER BY owner_id
;

# Merging the two tables to determine if some users have transactions or not
SELECT * 
FROM users u
INNER JOIN transactions t
ON u.id = t.owner_id
;

SELECT COUNT(DISTINCT(u.name))
FROM transactions t
INNER JOIN users u
ON u.id = t.owner_id
;
SELECT COUNT(DISTINCT(u.id))
FROM transactions t
INNER JOIN users u
ON u.id = t.owner_id
;

# this implies that out of 1867 total users, only 865  distinct users have transactions

#Joining the two table together and creating a temporary table known as new table

CREATE TEMPORARY TABLE new_table
SELECT *
FROM users u
INNER JOIN transactions t
ON u.id = t.owner_id
;

SELECT *
FROM new_table;
# grouping transactions by month and name; this will give al ist of transactions for each customer grouped by month

SELECT COUNT(savings_id) AS customer_transactions, MONTHNAME(transaction_date) AS months, owner_id,
ROW_NUMBER() OVER(PARTITION BY MONTHNAME(transaction_date)) AS row_num
FROM transactions
GROUP BY owner_id,MONTHNAME(transaction_date)
ORDER BY owner_id,MONTHNAME(transaction_date);

# this counted the number of transactions for each customer in each month

# calculate the average transactions per customer per month  by dividing the customer transactions by the number of months

SELECT SUM(customer_transactions)/COUNT(owner_id) AS avg_transactions_per_month,
owner_id
FROM (
SELECT COUNT(savings_id) AS customer_transactions, MONTHNAME(transaction_date) AS months, owner_id,
ROW_NUMBER() OVER(PARTITION BY MONTHNAME(transaction_date)) AS row_num
FROM transactions
GROUP BY MONTHNAME(transaction_date), owner_id
ORDER BY owner_id
) AS customer_monthly_transactions 
GROUP BY owner_id
ORDER BY 1 DESC;

# Make this a temporary table for easy access
CREATE TEMPORARY TABLE customer_trans
SELECT SUM(customer_transactions)/COUNT(owner_id) AS avg_transactions_per_month,
owner_id
FROM (
SELECT COUNT(savings_id) AS customer_transactions, MONTHNAME(transaction_date) AS months, owner_id,
ROW_NUMBER() OVER(PARTITION BY MONTHNAME(transaction_date)) AS row_num
FROM transactions
GROUP BY MONTHNAME(transaction_date), owner_id
ORDER BY owner_id
) AS customer_monthly_transactions 
GROUP BY owner_id
ORDER BY 1 DESC;

SELECT * FROM customer_trans;
SELECT owner_id,
avg_transactions_per_month,
CASE 
	WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
    WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
END AS 'frequency_category'
FROM customer_trans
;


# Find the total number of customers in each frequency distribution
SELECT frequency_category,
COUNT(owner_id) AS customer_count,
ROUND(AVG(avg_transactions_per_month),1) AS avg_transactions_per_month
FROM
(
SELECT owner_id,
avg_transactions_per_month,
CASE 
	WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
    WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
END AS 'frequency_category'
FROM customer_trans
) AS customer_trans
GROUP BY 1
ORDER BY 3 DESC
;