use sakila;

select * from  actor;

-- 1a. Display the first and last names of all actors from the table actor. 

select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
select upper(concat(first_name,' ',last_name)) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from actor
where first_name = "Joe";


-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name 
from actor
where last_name like '%Gen%';


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name 
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country;

select country_id, country
from country 
where country in ('Afghanistan', 'Bangladesh','China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor
add column middle_name varchar(20)
after first_name;

select * from actor;

-- 3b.You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor
modify column middle_name blob;

select * from actor;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;

select * from actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) 
from actor group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as 'Count of Last Name' 
from actor  group by last_name having count(last_name) > 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name = 'HARPO' 
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';
-- check
select first_name, last_name
from actor
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

-- first find the unique id

select first_name, last_name, actor_id
from actor
where first_name = 'HARPO' and last_name = 'WILLIAMS';

update actor set first_name = 
CASE
when (actor_id = 172 and first_name = 'HARPO') then 'GROUCHO'
when (actor_id = 172 and first_name <> 'HARPO') then 'MUCHO GROUCHO'
ELSE
first_name
END;

-- check
select first_name, last_name, actor_id
from actor
where actor_id= 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

show create table address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select s.first_name, s.last_name, coalesce(a.address, 'No Address Found in Table') as 'address'
from
staff as s
join
address a
on s.address_id = a.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select s.staff_id, s.first_name, s.last_name,  coalesce(concat('$', format(sum(p.amount), 2)), '$0') as amount 
from
staff  as s
join
payment as p
on
s.staff_id = p.staff_id
where
p.payment_date >= '2005-08-01 00:00:00'
and
p.payment_date <   '2005-08-02 00:00:00'
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select f.title, count(fa.actor_id) as 'Number of Actors'
from
film as f
inner join
film_actor as fa
on f.film_id = fa.film_id
group by f.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select f.title, count(i.film_id) as 'Number of Copies'
from
film as f
inner join
inventory as i
on
f.film_id = i.film_id
group by f.title
having f.title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name: Total amount paid

select c.first_name, c.last_name, sum(coalesce(p.amount, 0))
from customer as c
join
payment as p
on c.customer_id = p.customer_id
group by c.first_name, c.last_name
order by c.last_name asc;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select f.title
from film as f 
where
f.language_id in
(select l.language_id from language l where name = 'English')
and
f.title rlike '^[K,Q]';


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select a.first_name, a.last_name 
from actor as a
where
a.actor_id in
(select fa.actor_id from film_actor fa
 where fa.film_id = 
 (select f.film_id from film f where title = 'Alone Trip'));
 
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cust.first_name
      ,cust.last_name
      ,coalesce(cust.email, 'No Email Available') as 'Email'
from
customer cust
inner join
address as a
on cust.address_id = a.address_id
inner join
city
on a.city_id = city.city_id
inner join
country
on city.country_id = country.country_id
where
country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select f.title
from film f
inner join
film_category as fc
on
f.film_id = fc.film_id
inner join
category as c
on
fc.category_id = c.category_id
where
c.name = 'Family';


-- 7e. Display the most frequently rented movies in descending order.

select f.title, count(r.rental_id) as 'Number of Rentals'
from 
film as f
inner join
inventory as i
on f.film_id = i.film_id
inner join 
rental as r
on r.inventory_id = i.inventory_id
group by f.title
order by count(r.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select  s.store_id
       ,coalesce(concat('$', format(sum(p.amount), 2)), '$0') as amount
from
store as s
inner join
staff
on s.store_id = staff.store_id
inner join
payment as p
on staff.staff_id = p.staff_id
group by s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

select s.store_id
      ,city.city
      ,cntry.country
from
store as s
inner join
address as a
on s.address_id = a.address_id
inner join
city 
on
city.city_id = a.city_id
inner join
country cntry
on
city.country_id = cntry.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select catg.name
          ,coalesce(concat('$', format(sum(p.amount), 2)), '$0') as 'Gross Revenue'
from
category catg
inner join
film_category fc
on catg.category_id = fc.category_id
inner join
inventory i
on fc.film_id = i.film_id
inner join
rental r
on i.inventory_id = r.inventory_id
inner join 
payment p
on r.rental_id = p.rental_id
group by catg.name
order by coalesce(concat('$', format(sum(p.amount), 2)), '$0') desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres as
select catg.name
          ,coalesce(concat('$', format(sum(p.amount), 2)), '$0') as 'Gross Revenue'
from
category catg
inner join
film_category fc
on catg.category_id = fc.category_id
inner join
inventory i
on fc.film_id = i.film_id
inner join
rental r
on i.inventory_id = r.inventory_id
inner join 
payment p
on r.rental_id = p.rental_id
group by catg.name
order by coalesce(concat('$', format(sum(p.amount), 2)), '$0') desc
limit 5;

-- check
select * From top_five_genres;

-- 8b. How would you display the view that you created in 8a?

select * from top_five_genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_five_genres;








