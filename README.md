# DataAnalytics-Assessment
This is the solution to Cowrywise assessment quiz
# QUESTION 1: Identifying customers with atleast a plan sorted by total deposits
```markdown
# SQL Query Documentation

## Overview

This README summarizes an SQL query that gathers data from multiple tables related to user statistics in a financial application. The aim is to compile details on current users, including their savings, investments, and total deposits.

## Query Breakdown

### 1. SELECT Clause

The query retrieves specific user details:

```sql
SELECT id AS owner_id, 
name,
savings_count,
investment_count,
ROUND(total_deposits,0) AS total_deposits
```

- **owner_id**: User ID.
- **name**: User's name.
- **savings_count**: Number of savings accounts.
- **investment_count**: Number of investment accounts.
- **total_deposits**: Total deposits rounded to the nearest whole number.

### 2. FROM Clause

```sql
FROM current_users u
```

This clause selects data from the `current_users` table, containing active user records.

### 3. INNER JOINs

The query uses several `INNER JOIN` operations to combine data from:

```sql
INNER JOIN total_deposits td ON u.id = td.owner_id
INNER JOIN savings_per_user s ON u.id = s.owner_id
INNER JOIN investment_per_user iv ON u.id = iv.owner_id
```

These joins merge the details about total deposits, savings, and investments for each user.

### 4. ORDER BY Clause

```sql
ORDER BY total_deposits;
```

This orders the results by total deposits, allowing quick identification of users with the highest deposits.

## Challenges Encountered

1. **Data Integrity**: Ensuring data alignment across tables was essential for accuracy.
2. **Performance**: Handling large datasets effectively was a concern, so indexing foreign keys may be necessary.
3. **Column Ambiguity**: Using aliases to avoid confusion with identical column names was crucial.
4. **Understanding Relationships**: Familiarity with table relationships was required for accurate joins.

# QUESTION 2: Average number of transactions per customer per month
## Overview

This SQL query categorizes customers based on their average monthly transactions using data from the `customer_trans` table. It identifies three frequency categories—High, Medium, and Low Frequency—allowing businesses to better understand customer engagement.

## SQL Query Breakdown

```sql
SELECT frequency_category,
       COUNT(owner_id) AS customer_count,
       ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
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
ORDER BY 3 DESC;
```

### Key Components

1. **Inner Query**:
   - Retrieves `owner_id` and `avg_transactions_per_month`.
   - Uses a `CASE` statement to categorize based on transaction averages.

2. **Outer Query**:
   - Groups data by `frequency_category`.
   - Counts customers in each category and calculates the average transactions, rounded to one decimal.

## Functions Used

- `COUNT()`: Counts unique customers.
- `AVG()`: Computes the average transactions.
- `ROUND()`: Rounds the average for clarity.
- `CASE`: Implements conditional categorization.

## Challenges Faced

1. **Data Integrity**: Ensuring accurate recording of transaction data.
2. **Categorization Logic**: Selecting appropriate thresholds for frequency categories.
3. **Performance**: Query efficiency for large datasets.
4. **Edge Cases**: Handling zeros or NULL values in transaction data.

# Question 3: All active accounts with no transactions in the last 365 days
## Overview

This SQL query analyzes customer transaction behavior by categorizing customers into three frequency categories: High, Medium, and Low Frequency. It utilizes the `customer_trans` table to assess customer engagement.

## SQL Query Breakdown

```sql
SELECT frequency_category,
       COUNT(owner_id) AS customer_count,
       ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM
(
    SELECT owner_id,
           avg_transactions_per_month,
           CASE 
               WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
               WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
               ELSE 'Low Frequency'
           END AS frequency_category
    FROM customer_trans
) AS customer_trans
GROUP BY frequency_category
ORDER BY avg_transactions_per_month DESC;
```

### Breakdown of Components

1. **Inner Query**:
   - Selects `owner_id` and `avg_transactions_per_month`, categorizing each customer using a `CASE` statement based on average transaction values.

2. **Outer Query**:
   - Groups results by `frequency_category`, counting distinct customers and calculating the average transactions per category, rounded to one decimal place.

### Functions Used

- `COUNT()`: Counts unique customers in each category.
- `AVG()`: Calculates average transactions.
- `ROUND()`: Rounds the average to enhance readability.
- `CASE`: Defines the categorization logic.

## Challenges Faced

1. **Data Integrity**: Ensuring correct transaction data was vital to provide accurate categories.
2. **Threshold Selection**: Choosing effective criteria for categorization to reflect real customer behaviors.
3. **Performance Issues**: Optimizing the query for potentially large datasets without sacrificing accuracy.
4. **Handling Edge Cases**: Managing zero and NULL transaction values to avoid skewed results.

## Conclusion_3

This SQL query effectively categorizes customers based on transaction frequencies, providing insight into customer engagement. Such analysis can guide marketing strategies and enhance customer relationships.

# QUESTION 4: Customer Lifetime Value Estimation


## Conclusion

This SQL query effectively compiles user financial data for analysis and reporting. By addressing the outlined challenges, we can ensure clear and useful insights.
```
