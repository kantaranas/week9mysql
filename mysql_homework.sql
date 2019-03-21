-- WEEK 9 MYSQL HOMEWORK

USE sakila;
-- Display the first and last names of all actors from the table actor.
select 
	first_name, last_name 
from 
	actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
-- I used concat_ws to concatenate the name plus a space in between
select 
    upper(concat_ws(' ', first_name, last_name)) as `Actor Name`
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
select 
	actor_id, first_name, last_name 
from 
	actor 
where 
	first_name like 'Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
select 
	first_name, last_name 
from 
	actor 
where 
	last_name like '%GEN%';
    
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select 
	last_name, first_name 
from 
	actor 
where 
	last_name like '%LI%'
order by 
	last_name; 
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select 
	country_id, country 
from 
	country 
where 
	country in ('Afghanistan', 'Bangladesh', 'China');
    
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB.
alter table 
	actor
add column 
	description 
BLOB after last_update;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table 
	actor
drop column 
	description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select 
	last_name, 
count(*) as 'Last Name Count'
from actor 
group by last_name
order by `Last Name Count` desc;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select 
	last_name, 
count(*) as 'Last Name Count'
from actor 
group by last_name
having `Last Name Count` > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
select
actor_id, first_name, last_name
from actor
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- Write a query to fix the record.
update actor
set first_name = 'HARPO' 
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- not sure if the statment is to re-create from scratch or to view the structure, I opted to show the structure or design
use sakila; 
describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select 
staff.first_name, staff.last_name, address.address, address.district
from address 
join staff on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select 
	staff.staff_id, staff.first_name, staff.last_name,
sum(payment.amount) as 'Total Sales'
from payment
join staff on
staff.staff_id = payment.staff_id
where payment_date between '2005-08-01 00:00:00' and '2005-08-30'
group by staff.staff_id
order by sum(payment.amount);


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select
	film.title as Film_Title,
count(film_actor.actor_id) as Actor_Count
from film_actor
inner join film
on film.film_id = film_actor.film_id
group by Film_Title;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select i.film_id, i.store_id 
from inventory i where i.film_id in 
(select film_id from film f where title = "Hunchback Impossible");

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name

select customer.customer_id, customer.first_name, customer.last_name, 
sum(payment.amount) as total_payment
from payment
join customer on  customer.customer_id = payment.customer_id
group by customer.last_name
order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in 
-- popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select film.title from film where film.title like 'K%' or film.title like 'Q%'
and language_id in (select language_id from language where language_id = 1);
 
 
-- 7b. below are the individual queries to verify the results of the 7b subquery
select film_id, film.title from film where film.title = 'Alone Trip';
select film_actor.actor_id, film_actor.film_id from film_actor where film_id = 17;  

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select actor.first_name, actor.last_name from actor where actor.actor_id in
(select film_actor.actor_id from film_actor where film_actor.film_id in
(select film.film_id from film where film.title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select 
	customer.first_name, 
	customer.last_name, 
    customer.email, 
    city.city, 
    country.country
from customer 
join address on customer.address_id = address.city_id
join city on city.city_id = address.city_id
join country on country.country_id = city.country_id
where country.country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select film.title as 'Film Name'
from film 
where film.film_id in (
select film_category.film_id 
from film_category 
where film_category.category_id in (
select category.category_id 
from category 
where category.name = 'Family')
);     


-- 7e. Display the most frequently rented movies in descending order.

select film.title as 'Film Name', count(rental.rental_id) as 'Rental Count'
from film, inventory, rental
where film.film_id = inventory.film_id
and inventory.inventory_id = rental.inventory_id
group by title
order by  count(rental.rental_id) desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- get grand total to verify results below
select sum(amount) from payment;

-- query to answer question 7f
select 
	count(rental_id) as 'Total Rentals', 
    sum(amount) as 'Total $ Ammount', 
    store_id as 'Store' 
from payment join staff using (staff_id)
group by store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

select store_id, city, country from store join address using (address_id) join city using (city_id) join country using (country_id);


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)

select 
	category.name as 'Top 5 Genres', sum(payment.amount) as 'Total Revenue'
from category
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by category.name
order by sum(payment.amount)
limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_films as (
select category.name as 'Top 5 Genres', sum(payment.amount) as 'Total Revenue'
from category
join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id
group by category.name
order by sum(payment.amount) limit 5
);

-- 8b. How would you display the view that you created in 8a?

select * from top_five_films;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view sakila.top_five_films;