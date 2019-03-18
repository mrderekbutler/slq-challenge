-- 1a Display the first and last names of all actors from the table `actor'
SELECT
	actor.first_name,
    last_name
FROM sakila.actor
;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
	concat(first_name,' ', last_name) as 'Actor Name'
FROM sakila.actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
	actor_id,
    first_name,
    last_name
FROM sakila.actor
WHERE first_name = 'joe'
;

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
		actor.first_name,
        actor.last_name
FROM sakila.actor
WHERE last_name  like '%gen%'
;	

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
		actor.first_name,
        actor.last_name
FROM sakila.actor
WHERE last_name  like '%li%'
ORDER BY 
	last_name,
    first_name
;
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT
	country_id,
    country
FROM sakila.country
WHERE
	country in ('Afghanistan','Bangladesh', 'China')
;
    
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
ALTER TABLE sakila.actor
ADD COLUMN description BLOB AFTER last_name
;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER table sakila.actor
DROP COLUMN description
;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
	last_name,
	COUNT(last_name) 
FROM sakila.actor
GROUP BY
	last_name
;

-- 4b. List last names of actors and the number of actors who have that last name, but only 
-- for names that are shared by at least two actors
SELECT 
	actor.last_name,
	COUNT(actor.last_name) 
FROM sakila.actor
GROUP BY
	actor.last_name
HAVING COUNT(last_name) > 1
;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE sakila.actor
SET
    first_name = 'HARPO'
WHERE 	 
	actor_id = 172
;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE sakila.actor
SET
    first_name = 'GROUCHO'
WHERE 	 
	actor_id = 172
;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE sakila.address
;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT
	staff.first_name,
    staff.last_name,
    address.address
FROM sakila.staff
INNER JOIN sakila.address
 on address.address_id = staff.address_id
 ;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT 
	staff.staff_id,
	staff.first_name,
    staff.last_name,
    sum(payment.amount)
FROM sakila.staff
INNER JOIN sakila.payment
 on payment.staff_id = staff.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY
	staff.staff_id,
	staff.first_name,
    staff.last_name
ORDER BY
	staff.staff_id,
	staff.first_name,
    staff.last_name
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
	film.title,
    count(film_actor.actor_id) as 'Number of Actors'
FROM sakila.film
INNER JOIN sakila.film_actor
 on film_actor.film_id = film.film_id
GROUP BY
	film.title
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
	film.film_id,
	film.title,
    count(inventory.inventory_id) as 'Number of Copies'
FROM sakila.film
INNER JOIN sakila.inventory
 on inventory.film_id = film.film_id
where film.title = 'Hunchback Impossible'
GROUP BY
	film.film_id,
	film.title
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
	customer.customer_id,
	customer.first_name,
    customer.last_name,
    sum(payment.amount) 'Total Paid by Customer'
FROM sakila.customer
INNER JOIN sakila.payment
 on payment.customer_id = customer.customer_id
GROUP BY
	customer.customer_id,
	customer.first_name,
    customer.last_name
ORDER BY
	customer.last_name,
    customer.first_name
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the 
-- letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT
	film.title
FROM sakila.film
WHERE (film.title like 'k%'
   OR film.title like 'q%') 
  AND film.language_id in (
	SELECT 
		language.language_id
	FROM sakila.language
    WHERE language.name = 'English')
;
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT
	actor.first_name,
    actor.last_name
FROM sakila.actor
WHERE  
	actor.actor_id in (
 	SELECT 
		film_actor.actor_id
	FROM sakila.film_actor
    WHERE film_actor.film_id in ( 
		SELECT 
			film.film_id
		FROM sakila.film
		WHERE film.title = 'Alone Trip'))
        
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT
	customer.first_name,
    customer.last_name,
    customer.email,
    country.country
FROM sakila.customer
INNER JOIN sakila.address
 on address.address_id = customer.address_id
INNER JOIN sakila.city
 on city.city_id = address.city_id
INNER JOIN sakila.country
 on country.country_id = city.country_id
WHERE  
	country.country = 'canada'
;
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT
	film.title
FROM sakila.film
INNER JOIN sakila.film_category
 on film_category.film_id = film.film_id
INNER JOIN category 
 on category.category_id = film_category.category_id
WHERE category.name = 'family'
;

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
	film.title,
    count(rental.rental_id) as Num_Rentals 
FROM rental
INNER JOIN sakila.inventory
 on inventory.inventory_id = rental.inventory_id
INNER JOIN sakila.film
 on film.film_id = inventory.film_id
GROUP BY
	film.title
ORDER BY
	Num_Rentals desc
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
	store.store_id,
    SUM(payment.amount) as TotalSales 
FROM sakila.payment
INNER JOIN sakila.rental
 on rental.rental_id = payment.rental_id
INNER JOIN sakila.inventory
 on inventory.inventory_id = rental.inventory_id
INNER JOIN sakila.store
 on store.store_id  = inventory.store_id
GROUP BY
	store.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
	store.store_id,
    city.city,
    country.country
FROM sakila.store
INNER JOIN sakila.address
 on address.address_id = store.address_id 
INNER JOIN sakila.city
 on city.city_id = address.city_id
INNER JOIN sakila.country
 on country.country_id = city.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)
SELECT 
	category.name,
    SUM(payment.amount) as GrossRevenue 
FROM sakila.category
INNER JOIN sakila.film_category
 on film_category.category_id = category.category_id
INNER JOIN sakila.inventory
 on inventory.film_id = film_category.film_id
INNER JOIN sakila.rental
 on rental.inventory_id = inventory.inventory_id
INNER JOIN sakila.payment
 on payment.rental_id  = rental.rental_id
GROUP BY
	category.name
ORDER BY
	GrossRevenue DESC LIMIT 5;

;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS sakila.category_top5_revenue; 
CREATE VIEW sakila.category_top5_revenue AS
SELECT 
	category.name,
    SUM(payment.amount) as GrossRevenue 
FROM sakila.category
INNER JOIN sakila.film_category
 on film_category.category_id = category.category_id
INNER JOIN sakila.inventory
 on inventory.film_id = film_category.film_id
INNER JOIN sakila.rental
 on rental.inventory_id = inventory.inventory_id
INNER JOIN sakila.payment
 on payment.rental_id  = rental.rental_id
GROUP BY
	category.name
ORDER BY
	GrossRevenue DESC LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM sakila.category_top5_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS sakila.category_top5_revenue;
    



    
