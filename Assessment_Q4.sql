USE adashi_staging;

# carefully examine both needed tables
SELECT *
FROM users_customuser;

SELECT *
FROM savings_savingsaccount;

# filter out specific columns with needed information
SELECT id, 
name,
date_joined
FROM users_customuser
WHERE is_account_deleted = 0;

# use a subquery to determine the difference between the date joined and current date as well as specifying the unit of time as month to get  the precise difference and a library function

SELECT id,
name,
date_joined,
TIMESTAMPDIFF(MONTH, date_joined, NOW()) AS tenure_months
FROM (
SELECT id, 
name,
date_joined
FROM users_customuser
) AS data_table
;

# CREATE a table for the tenure months information
CREATE TABLE tenured_users
SELECT id,
name,
date_joined,
TIMESTAMPDIFF(MONTH, date_joined, NOW()) AS tenure_months
FROM (
SELECT id, 
name,
date_joined
FROM users_customuser
) AS data_table
;

SELECT * FROM savings_savingsaccount;

# selecct specified columns from the savings table
SELECT savings_id,
confirmed_amount,
owner_id
FROM savings_savingsaccount
WHERE transaction_status LIKE '%success%';

# calculate profit for each transaction using a subquery, make this a CTE so as to be used in the next query

SELECT owner_id,
confirmed_amount,
confirmed_amount * 0.001 AS profit_per_transaction
FROM (
SELECT savings_id,
confirmed_amount,
owner_id
FROM savings_savingsaccount
WHERE transaction_status LIKE '%success%'
) AS profits
ORDER BY 3 DESC; 

# create a table for easy readability 
CREATE TABLE transactions_profits
WITH profit_expression AS 
(
SELECT owner_id,
confirmed_amount,
confirmed_amount * 0.001 AS profit_per_transaction
FROM (
SELECT savings_id,
confirmed_amount,
owner_id
FROM savings_savingsaccount
WHERE transaction_status LIKE '%success%'
) AS profits 
)
# calculate the average profit per transaction and total transactions reusing the cte just created
SELECT owner_id,
COUNT(owner_id) AS total_transactions,
ROUND(AVG(profit_per_transaction),0) AS avg_profit_per_transactions
FROM profit_expression
GROUP BY 1;

# estimate the clv out using the formula provided in the instructions manual

# create a new column in the transactions_profits table
ALTER TABLE transactions_profits ADD COLUMN estimated_clv INT;
SELECT * 
FROM transactions_profits;

SELECT *
FROM tenured_users t
JOIN transactions_profits tp 
	ON t.id = tp.owner_id
;

# use a subquery to calculate the estimated clv column
SELECT ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transactions,2) AS clv
FROM (
SELECT *
FROM tenured_users t
JOIN transactions_profits tp 
	ON t.id = tp.owner_id
    ) AS last_table
;

# drop the column to create a new one after merging both tables
ALTER TABLE transactions_profits
DROP COLUMN estimated_clv; 

# add the new column to the merged tables
SELECT *,
ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transactions,2) AS estimated_clv
FROM tenured_users t
JOIN transactions_profits tp 
	ON t.id = tp.owner_id
;

# organize the table in the required format
SELECT id AS customer_id,
name,
tenure_months,
total_transactions,
ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transactions,2) AS estimated_clv
FROM tenured_users t
JOIN transactions_profits tp 
	ON t.id = tp.owner_id
ORDER BY estimated_clv DESC
;