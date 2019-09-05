/*  
<< SQL 觀念說明 >> 
Version: 2019-09-04 v1.0
*/

use sakila;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- -----------------------------
-- 基本查詢架構
-- -----------------------------
select * from (
	SELECT 
		r.rental_date,
		c.email,
		f.title,
		f.rating,
		ca.`name` as category_name
	FROM sakila.rental as r
		left join customer c on c.customer_id = r.customer_id
		left join inventory as i on i.inventory_id = r.inventory_id
		left join film as f on f.film_id = i.film_id
		left join film_category as fc on fc.film_id = f.film_id
		inner join category as ca on ca.category_id = fc.category_id and ca.name <> 'Action'
	where 
		date(rental_date) between '2005-05-24' and '2005-05-30'
		and c.customer_id in (
			select customer_id from sakila.rental where return_date between '2005-05-01' and '2005-05-22'
            )
		and c.email is not null
	order by r.rental_date desc
) as tmp
group by rental_date, email
having rental_date > '2019-05-25'
;


-- -----------------------------
-- 常用功能說明
-- -----------------------------

-- case when [] then [] else [] end
-- count([]) / count(distinct [])

-- like: 找相似 -> %可理解成任意字段
SELECT * FROM sakila.customer where last_name like '%tim%' or first_name like '%tim%';   -- 所有字段包含 ％％夾著的字
SELECT * FROM sakila.customer where last_name like '%tim' or first_name like '%tim'; 

SELECT * FROM sakila.customer where last_name like '%tim' or first_name like '%tim';    -- 	以％後字段結尾
SELECT * FROM sakila.customer where last_name like 'im%' or first_name like 'im%';    -- 以％前字段開頭

-- between 
-- in



