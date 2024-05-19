delete
from mart.f_customer_retention
where period_id=(select week_of_year from mart.d_calendar where date_actual = '{{ds}}'::DATE);

with client_orders_per_period_count as 
(select extract(week FROM date_time) as period_id,
customer_id,
item_id,
count(distinct uniq_id) as total_orders,
count(distinct case when status = 'refunded' then uniq_id end) as refunded_orders,
sum(payment_amount) as total_payment_amount,
sum(case when status = 'shipped' then payment_amount end) as shipped_payment_amount,
sum(case when status = 'refunded' then payment_amount end) as refunded_payment_amount
from staging.user_order_log
group by 1, 2, 3),

customer_retention_calculations as 
(select period_id,
item_id,
count(distinct case when total_orders = 1 then customer_id end) as new_customers_count,
count(distinct case when total_orders > 1 then customer_id end) as returning_customers_count,
count(distinct case when refunded_orders > 0 then customer_id end) as refunded_customer_count,
sum(case when total_orders = 1 then shipped_payment_amount end) as new_customers_revenue,
sum(case when total_orders > 1 then shipped_payment_amount end) as returning_customers_revenue,
sum(refunded_orders) as customers_refunded
from client_orders_per_period_count
group by 1, 2
order by item_id desc)

insert into mart.f_customer_retention (item_id, period_id, new_customers_count, returning_customers_count, 
										refunded_customer_count, new_customers_revenue, returning_customers_revenue, customers_refunded)
select item_id, 
period_id, 
new_customers_count, 
returning_customers_count, 
refunded_customer_count, 
new_customers_revenue, 
returning_customers_revenue, 
customers_refunded
from customer_retention_calculations crc
where period_id = (select week_of_year from mart.d_calendar where date_actual = '{{ds}}'::DATE);