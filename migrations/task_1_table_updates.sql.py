--обновляем таблицу user_order_log - добавляем столбец 'status'
ALTER TABLE staging.user_order_log 
ADD COLUMN status varchar(15) NOT NULL Default 'shipped';

--добавляем ту же колонку в f_sales
ALTER TABLE mart.f_sales ADD COLUMN status varchar(20) NOT NULL Default 'shipped';