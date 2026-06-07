use celebal_week2;

-- Section A — SQL Basics (SELECT, Constraints, Primary Keys)

-- Q1
select * from customers;

-- Q2
select first_name,last_name,city from customers;

-- Q3 
select distinct category from products;

-- Q4
/*
Primary Keys:
customers    -> customer_id
products     -> product_id
orders       -> order_id
order_items  -> item_id

A Primary Key uniquely identifies each record in a table.
It must be UNIQUE so that no two rows have the same identifier.
It must be NOT NULL because every record must have a valid identifier.
Without a unique and non-null primary key, records cannot be uniquely identified.
*/

-- Q5
/*
The email column has two constraints:

1. UNIQUE
   - Ensures that each customer has a different email address.
   - Duplicate email values are not allowed.

2. NOT NULL
   - Ensures that every customer record must have an email address.
   - NULL values cannot be inserted.

If a duplicate email is inserted, the database will return an error because the UNIQUE constraint will be violated.
*/

-- Q6
/*
we will comment the q6 because when we run whole script this will generate an error

insert into products values(209,'Lamp','Electronics','philips',-50, 10)
select * from products;


This query will generate an error because the unit_price is negative.

The products table has the constraint:

check (unit_price > 0)

Since -50 is less than 0, it violates the CHECK constraint.
Therefore, the database rejects the insertion and prevents invalid data from being stored.
*/

-- Section B — Filtering & Optimization (WHERE, Indexes)

-- Q7
select * from orders
where status = 'Delivered';
 
-- Q8
select * from products
where category = 'electronics' and unit_price > 2000;

-- Q9
select * from customers
where year(join_date) = 2024 and state = 'maharashtra'

-- Q10

select * from orders
where order_date between '2024-08-10' and '2024-08-25'
and status <> 'cancelled';


-- Q11

/*
The idx_orders_date index is created on the order_date column of the orders table.

It helps the database find records faster when queries are filtered using order_date. Instead of checking every row in the table, the database can use the index to locate matching records more efficiently.

Example Query:

SELECT *
FROM orders
WHERE order_date = '2024-08-15';
*/


-- Q12

/*
No, the index on join_date will not be used efficiently in this query because the YEAR() function is applied to the column.

When a function is used on an indexed column, the database may need to check each row instead of directly using the index.

A better query would be:

SELECT *
FROM customers
WHERE join_date >= '2024-01-01'
AND join_date < '2025-01-01';

This query is more efficient because it allows the database to use the index on join_date directly.
*/

-- Section C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX)

-- Q13
 select count(*) as total_orders from orders;

-- Q14

select sum(total_amount) from orders where status = 'delivered';

-- Q15
select category,avg(unit_price) from products  group by category;

-- Q16
select status, count(*) as order_count,sum(total_amount) as total_revenue
from orders
group by status
order by total_revenue desc;

-- Q17
select category,max(unit_price),min(unit_price) from products group by category;

-- Q18
select category,
avg(unit_price) from products 
group by category
having avg(unit_price)>2000;

-- Section D — Joins & Relationships

-- Q 19
select o.order_id, o.order_date, c.first_name, c.last_name, o.total_amount
from orders o
inner join customers c
on o.customer_id = c.customer_id;

-- Q20
select c.customer_id, c.first_name, c.last_name, o.order_id, o.order_date
from customers c
left join orders o
on c.customer_id = o.customer_id;

-- Q21
select o.order_id, p.product_name, oi.quantity, oi.unit_price, oi.discount_pct
from orders o
join order_items oi
on o.order_id = oi.order_id
join products p
on oi.product_id = p.product_id;

-- Q22
/*
left join returns all records from the left table and matching records from the right table.
if no match is found, null values are returned for the right table.

right join returns all records from the right table and matching records from the left table.
if no match is found, null values are returned for the left table.

a full outer join returns all records from both tables, whether there is a match or not.
it is useful when we want to see all records from both tables including unmatched records.
*/

-- Q23
/*
foreign key relationships:

orders.customer_id references customers.customer_id

order_items.order_id references orders.order_id

order_items.product_id references products.product_id

if we try to insert an order with customer_id = 999 and that customer does not exist in the customers table, the database will return a foreign key constraint error and the record will not be inserted.
*/

-- Section E — Advanced Concepts (CASE, ACID, Transactions)

-- Q24
select product_name,
       unit_price,
       case
           when unit_price < 1000 then 'Budget'
           when unit_price between 1000 and 3000 then 'Mid-Range'
           else 'Premium'
       end as price_tier
from products;

-- Q25
select
count(case when status = 'Delivered' then 1 end) as delivered_orders,
count(case when status <> 'Delivered' then 1 end) as not_delivered_orders
from orders;

-- Q26
/*
A - Atomicity
A transaction is completed fully or not executed at all.

C - Consistency
The database remains in a valid state before and after a transaction.

I - Isolation
Multiple transactions do not interfere with each other.

D - Durability
Once a transaction is committed, the changes are permanently saved.

Example:
In a bank transfer, money is deducted from one account and added to another.
If any step fails, the whole transaction is rolled back.
This ensures data accuracy and reliability.
*/

-- Q27
start transaction;

insert into orders
values (1012, 102, curdate(), 'Pending', 1598.00);

insert into order_items
values
(5018, 1012, 206, 1, 1299.00, 0),
(5019, 1012, 208, 1, 599.00, 0);

update products
set stock_qty = stock_qty - 1
where product_id = 206;

update products
set stock_qty = stock_qty - 1
where product_id = 208;

commit;

select * from orders where order_id = 1012;

/*
If any step fails, rollback should be executed so that all changes made in the transaction are undone.
Otherwise, commit is executed to save all changes permanently.
*/