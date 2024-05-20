DROP TABLE IF EXISTS mart.f_customer_retention;

CREATE TABLE IF NOT EXISTS mart.f_customer_retention (
	id serial,
	item_id bigint,
	period_id integer,
	period_name varchar(10) DEFAULT 'weekly',
	new_customers_count integer,
	returning_customers_count integer,
	refunded_customer_count integer, 
	new_customers_revenue NUMERIC(14, 2),
	returning_customers_revenue NUMERIC(14, 2),
	customers_refunded integer,
	PRIMARY KEY(id)
	)