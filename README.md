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

## Conclusion

This SQL query effectively compiles user financial data for analysis and reporting. By addressing the outlined challenges, we can ensure clear and useful insights.
```
