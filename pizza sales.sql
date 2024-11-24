-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
    -- Calculate the total revenue generated from pizza sales.
SELECT
 ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM pizzas p
        JOIN order_details o ON p.pizza_id = o.pizza_id;
        
        -- Identify the highest-priced pizza.

SELECT 
pt.name, p.price AS highest_price
FROM
pizzas p JOIN
pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
p.size,
 COUNT(o.order_details_id) AS order_count
     FROM
order_details o
        JOIN
pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;


-- List the top 5 most ordered pizza types 
-- along with their quantities.

SELECT 
p.name, SUM(o.quantity) AS quantity
    FROM
pizza_types p
   JOIN
pizzas pi ON p.pizza_type_id = pi.pizza_type_id
	JOIN
order_details o ON o.pizza_id = pi.pizza_id
GROUP BY p.name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables/ to find the 
-- total quantity of each pizza category ordered

SELECT 
SUM(o.quantity) AS quantity, p.category
     FROM
pizza_types p
        JOIN
pizzas pi ON p.pizza_type_id = pi.pizza_type_id
        JOIN
order_details o ON o.pizza_id = pi.pizza_id
GROUP BY p.category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hour of the day.

SELECT 
HOUR(order_time) AS hour, 
COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as name from pizza_types
group by category;


-- Group the orders by date and calculate 
-- the average number of pizzas ordered per day.

SELECT 
ROUND(AVG(quantity), 0) AS avg_quantity
FROM
    (SELECT 
	o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quanitity;
    
    -- Determine the top 3 most ordered 
-- pizza types based on revenue

select pt.name, sum(od.quantity * p.price) as revenue
from pizza_types pt join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.name order by revenue desc limit 3;



-- Calculate the percentage contribution of each pizza type to total revenue.-- 
select pt.category , round(sum(od.quantity * p.price)/ 
(select round(sum(od.quantity * p.price),2) as total_sales
from order_details od
join 
pizzas p on p.pizza_id = od.pizza_id)*100, 2) as
revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time.-- 


select order_date, sum(revenue) 
over(order by order_date) as cum_revenue
from
 (select o.order_date, 
 sum(od.quantity * p.price) as revenue
from order_details od join pizzas p
on od.pizza_id = p.pizza_id
join orders o on o.order_id = od.order_id
group by o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select name, revenue from  
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pt.category, pt.name,
sum((od.quantity)* p.price) as revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od on
od.pizza_id = p.pizza_id
group by pt.category, pt.name) as a) as b
where rn <= 3;
    
