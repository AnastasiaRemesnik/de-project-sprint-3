DELETE FROM
	mart.f_customer_retention
WHERE
	period_id =(
	SELECT
		week_of_year
	FROM
		mart.d_calendar
	WHERE
		date_actual = '{{ds}}'::DATE);

WITH client_orders_per_period_count AS 
(
SELECT
	EXTRACT(week FROM date_time) AS period_id,
	customer_id,
	item_id,
	count(DISTINCT uniq_id) AS total_orders,
	count(DISTINCT CASE WHEN status = 'refunded' THEN uniq_id END) AS refunded_orders,
	sum(payment_amount) AS total_payment_amount,
	sum(CASE WHEN status = 'shipped' THEN payment_amount END) AS shipped_payment_amount,
	sum(CASE WHEN status = 'refunded' THEN payment_amount END) AS refunded_payment_amount
FROM
	staging.user_order_log
GROUP BY
	1,
	2,
	3),

customer_retention_calculations AS 
(
SELECT
	period_id,
	item_id,
	count(DISTINCT CASE WHEN total_orders = 1 THEN customer_id END) AS new_customers_count,
	count(DISTINCT CASE WHEN total_orders > 1 THEN customer_id END) AS returning_customers_count,
	count(DISTINCT CASE WHEN refunded_orders > 0 THEN customer_id END) AS refunded_customer_count,
	sum(CASE WHEN total_orders = 1 THEN shipped_payment_amount END) AS new_customers_revenue,
	sum(CASE WHEN total_orders > 1 THEN shipped_payment_amount END) AS returning_customers_revenue,
	sum(refunded_orders) AS customers_refunded
FROM
	client_orders_per_period_count
GROUP BY
	1,
	2
ORDER BY
	item_id DESC)

INSERT INTO
	mart.f_customer_retention (
	item_id,
	period_id,
	new_customers_count,
	returning_customers_count, 
	refunded_customer_count,
	new_customers_revenue,
	returning_customers_revenue,
	customers_refunded)
SELECT
	item_id,
	period_id,
	new_customers_count,
	returning_customers_count,
	refunded_customer_count,
	new_customers_revenue,
	returning_customers_revenue,
	customers_refunded
FROM
	customer_retention_calculations crc
WHERE
	period_id = (
	SELECT
		week_of_year
	FROM
		mart.d_calendar
	WHERE
		date_actual = '{{ds}}'::DATE);