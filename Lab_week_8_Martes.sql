-- In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.

-- Instructions
-- How many copies of the film Hunchback Impossible exist in the inventory system?
-- List all films whose length is longer than the average of all the films.
-- Use subqueries to display all actors who appear in the film Alone Trip.
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
-- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

-- How many copies of the film Hunchback Impossible exist in the inventory system?

use Sakila;

SELECT COUNT(*) AS copies_of_hunchback_impossible
FROM inventory
JOIN film ON inventory.film_id = film.film_id
WHERE film.title = 'Hunchback Impossible';

-- List all films whose length is longer than the average of all the films.

SELECT *
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
);

-- con esto vemos que la media es 115 por lo que verificamos esta ok el código de arriba
SELECT AVG(length) AS average_length
FROM film;

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id = (
        SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
    )
);

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title AS movie_title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- ahora con una subquery

SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_category
    WHERE category_id = (
        SELECT category_id
        FROM category
        WHERE name = 'Family'
    )
);

-- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- ahora con una subquery

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);

-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT actor_id, COUNT(*) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;

-- con esta consulta vemos que actor y ahora vamos a ver en que películas haciendo una subconsulta

SELECT f.title AS film_title
FROM film_actor fa
JOIN film f ON fa.film_id = f.film_id
WHERE fa.actor_id = (SELECT actor_id
                     FROM film_actor
                     GROUP BY actor_id
                     ORDER BY COUNT(*) DESC
                     LIMIT 1);

-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
-- el cliente más rentable 
SELECT customer_id, SUM(amount) AS total_payments
FROM payment
GROUP BY customer_id
ORDER BY total_payments DESC
LIMIT 1;

-- ahora podeos usar el su Id para econtrar las pelis que alquilo igual que arriba
SELECT f.title AS film_title
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE p.customer_id = (SELECT customer_id
                       FROM payment
                       GROUP BY customer_id
                       ORDER BY SUM(amount) DESC
                       LIMIT 1);

-- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
-- Para obtener este client_id y el total podemos calcular primero el promedio del gasto total por cliente y luego usar ese valor de esta manera:

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_amount) FROM (
        SELECT SUM(amount) AS total_amount
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
)
ORDER BY total_amount_spent DESC;

