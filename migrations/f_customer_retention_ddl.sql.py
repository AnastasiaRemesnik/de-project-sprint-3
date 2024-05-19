drop table if exists mart.f_customer_retention;

create table if not exists mart.f_customer_retention (
id serial,
item_id bigint,
period_id integer,
period_name varchar(10) default 'weekly',
new_customers_count integer,
returning_customers_count integer,
refunded_customer_count integer, 
new_customers_revenue numeric(14, 2),
returning_customers_revenue numeric(14, 2),
customers_refunded integer,
primary key(id)
);