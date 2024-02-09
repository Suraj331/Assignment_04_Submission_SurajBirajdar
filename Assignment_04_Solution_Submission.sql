USE mavenmovies;


-- Q1. Identify a table in the sakila database that violates 1NF. 
-- Explain how you would normalize it to achieve 1NF.
/*****************************************************************************************
In the provided database schema, the film_category table appears to have a potential violation of 
the First Normal Form (1NF). 
The film_category table has a composite primary key consisting of two columns: film_id and category_id. 
This composite primary key suggests that the table may have a many-to-many relationship 
between films and categories.
*/
CREATE TABLE film_category_association (
  association_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  film_id SMALLINT UNSIGNED NOT NULL,
  category_id TINYINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (association_id),
  CONSTRAINT fk_association_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_association_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

/*
'film_category_association' represents the association between films and categories, with a new surrogate key (association_id) as the primary key.
This normalization ensures that each table adheres to the First Normal Form (1NF) by having atomic values in each column and resolving the potential violation associated with the composite primary key.
*/


/*************************************************************************************************/

-- Q2. Choose a table in sakila and describe how you would determine whether it is i in 2NF. If it violates 
-- 2NF explain steps to normalize it.

-- ANS
/*
-- The potential violation arises from the non-prime attribute language_id being partially dependent on the primary key (film_id). 
-- If multiple films have the same language_id, it suggests a partial dependency on the composite key (film_id, language_id).

-- To normalize the table to 2NF, you could create a new table for languages, removing the dependency on the composite key. 
-- This modification ensures that the language_id is now fully dependent on its own primary key in the language table, resolving the 2NF violation in the film table.

*/

/********************************************************************************************************/


-- Q3. Identify the sakila that violates 3NF. Describe the transitive dependencies present and outline the unnormalized part upto at least 2NF.

-- ANS

-- Looking at the Sakila database, the film table seems to violate the Third Normal Form (3NF) due to transitive dependencies.

-- One potential transitive dependency is between original_language_id and language_id, where original_language_id depends on language_id. If we consider original_language_id as the dependent attribute and language_id as the determinant, we can identify this transitive dependency.

-- To normalize the film table to 3NF, we need to remove the transitive dependency. Here are the steps:

-- Create a New Table for Languages:
-- Create a new table named language to store language information, with language_id as the primary key.

CREATE TABLE language (
  language_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (language_id)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;


-- Update film Table:
-- Remove the original_language_id column from the film table and replace it with a foreign key constraint referencing the language table.

ALTER TABLE film
ADD CONSTRAINT fk_film_language_new
FOREIGN KEY (original_language_id)
REFERENCES language (language_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE film
DROP COLUMN original_language_id;


-- By performing these steps, we eliminate the transitive dependency in the film table and achieve 3NF normalization.


/*******************************************************************************************************************************/



-- Q4. Take a specific table in a sakila and guide through the process of normalizing it from the initial unnormalized form upto at least 2NF.

-- ANS

-- Let's consider the payment table from the Sakila database and guide through the process of normalizing it up to at least the Second Normal Form (2NF).

-- Initial Unnormalized Form (UNF):
-- The payment table contains information about payments made by customers, including the payment amount, payment date, customer ID, staff ID, and rental ID.

-- First Normal Form (1NF):
-- The payment table is already in 1NF because each column holds atomic values, and there are no repeating groups.

-- Second Normal Form (2NF):
-- To achieve 2NF, we need to identify any partial dependencies and remove them by splitting the table into two or more tables.

-- Analysis:
-- Looking at the payment table, we can see that the payment_amount, payment_date, customer_id, staff_id, and rental_id attributes all appear to be independent.

-- Create a New Table for Payments:
-- We'll create a new table named payment_details to store payment-specific information.

CREATE TABLE payment_details (
  payment_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_amount DECIMAL(5,2) NOT NULL,
  payment_date DATETIME NOT NULL,
  PRIMARY KEY (payment_id)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;


-- Modify payment Table:
-- We'll remove the payment_amount and payment_date columns from the payment table and replace them with a foreign key constraint referencing the payment_details table.

ALTER TABLE payment
ADD COLUMN payment_id SMALLINT UNSIGNED NOT NULL,
ADD CONSTRAINT fk_payment_details
FOREIGN KEY (payment_id)
REFERENCES payment_details (payment_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- Update Data:
-- We need to update the payment table to set appropriate values for the payment_id column based on the payment details.

UPDATE payment p
JOIN payment_details pd ON p.payment_amount = pd.payment_amount
AND p.payment_date = pd.payment_date
SET p.payment_id = pd.payment_id;


-- y following these steps, we've normalized the payment table up to the Second Normal Form (2NF) 
-- by removing the partial dependencies between payment attributes. Now, the payment table conforms to 2NF.

/************************************************************************************************************************************************************************************************************************/




-- CTE Basics --
-- Q1. Write a query using cte to retrieve the distinct list of actor names and number of films 
-- they have acted in from the actor and film_actor table
with actorCount as( 
select  a.actor_id, a.first_name, a.last_name, count(distinct film_id) Film_count  from actor a
join film_actor fa on fa.actor_id = a.actor_id
group by actor_id, first_name, last_name
)
select
actor_id,
first_name,
last_name,
Film_count
from actorCount;


-- Recursive CTE --
-- Q2. Use recursive cte to generate a hierachical list of catagories and their subcatagories from the catagory table



-- CTE with Joins --
-- Q3. Create  a cte that combines information from the film and 
-- language tables to display the film title, language name, and rental rate.
with combined_table as (
select 
title, lan.name audio, rental_rate 
from film f 
join language lan on  lan.language_id = f.language_id
)
select
title, audio, rental_rate
from combined_table;



-- CTE for Aggregation --
-- Q4. Write a query using cte to find the total revenue 
-- generated by each customer (sum of payments) from the customer and payment tables.

with Total_revenue as (
select c.customer_id, sum(amount) amount from customer c 
join payment p on c.customer_id = p.customer_id
group by customer_id 
)
select
customer_id, amount
from Total_revenue;



-- CTE with Window Function --
-- Q5. Utilize a cte with a window function to rank films 
-- based on their rental duration from the film table. 

with film_ranking as (
select 
film_id, rental_duration,
rank() over(partition by film_id order by rental_duration desc) as rnk
 from film 
 order by rental_duration desc
)
select
film_id,
rental_duration,
rnk
from film_ranking;

-- CTE filtering --
-- Q6. Create a cte to list customers who have made more than two rentals , 
-- and then join this cte with the customer table to retrieve additional customer details.

with total_rentals as (
select 
c.customer_id, count(rental_id) rentals
from customer c 
join rental r on r.customer_id = c.customer_id
group by c.customer_id
having rentals > 2
)
select
*from total_rentals tr
join customer ct on ct.customer_id = tr.customer_id;


-- CTE date calculation --
-- Q7. Write a query using a cte to find the total number of rentals made each month, 
-- considering the rental_date from rental table.
with total_rentals as (
select
 count(rental_id) rentals, monthname(rental_date) Months
from rental
group by months
)
select
rentals,
Months
from total_rentals;


-- CTE for pivot operation --
-- Q8. Use cte to pivot data from the payment table to display the total payments made 
-- by each customer in separate column for different payment methods.

with customer_payment as (
select c.customer_id, count(payment_id) total_payments 
from payment p 
join customer c on p.customer_id = c.customer_id 
group by c.customer_id)

select 
customer_id, total_payments
from customer_payment;

-- CTE self-join -- 
-- Q9. Create a cte to generate a report showing pairs of actors who have appeared 
-- in the same film together using the film_actor table
with actor_pairs as (
select 
fa.actor_id as actor_1, ft.actor_id as actor_2,
title 
from film_actor fa
join  film_actor ft on fa.film_id = ft.film_id and fa.actor_id < ft.actor_id
join film f on fa.film_id = f.film_id
)
select
actor_1,
actor_2,
title
from actor_pairs;



-- CTE for recursive search --
-- Q10. Implement a recursive cte to find all employees in the staff table who 
-- report to specific manager considering the reports_to column

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        staff_id,
        first_name,
        last_name,
        reports_to
    FROM
        staff
    WHERE
        staff_id = 2  -- Replace :specific_manager_id with the actual manager's ID
    UNION ALL
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.reports_to
    FROM
        staff s
    JOIN
        EmployeeHierarchy eh ON s.reports_to = eh.staff_id
)

SELECT
    staff_id,
    first_name,
    last_name,
    reports_to
FROM
    EmployeeHierarchy;






















