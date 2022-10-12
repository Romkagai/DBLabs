-----------
/* 1 Найти среднюю стоимость пиццы с точность до второго знака. Выборка должна содержать только одно число. */

select round(avg(price), 2) as avg_pizza_price
from pd_products
where category ilike 'Пицца';

-----------
/* 2 Найти количество отменённых и просроченных заказов. Все атрибуты должны иметь имя. */

select count(case when order_state ILIKE 'CANCEL' then id end) as cancelled_order,
       count(case when exec_date > delivery_date then id end) as out_of_time_order
from pd_orders;



-----------
/* 3 Найти среднюю стоимость для каждой категории товара с точность до второго знака.
   А так же на какой процент максимальная и минимальная стоимости отклоняются от средней стоимости.
   Выборка должна содержать наименование категории, среднюю стоимость и величины отклонения в процентах (округлить до второго знака). */

select category, trunc(avg(price), 2) as avg_category_price,
        trunc(max(price) / trunc(avg(price), 2) * 100 - 100, 2) as max_price_deviation,
        trunc(100 - min(price) / trunc(avg(price), 2) * 100 ,2) as min_price_deviation
from pd_products
group by category;

-----------
/* 4 Для каждой из должностей найдите средний, максимальный и минимальный возраст сотрудников.
   Выборка должна название должности и средний, максимальный и минимальный возраст. */

select post,
        extract (year from avg(age(current_date, birthday))) as average_age,
        extract (year from max(age(current_date, birthday))) as max_age,
        extract (year from min(age(current_date, birthday))) as min_age
from pd_employees
group by post;

/* 5 Для каждого заказа, сделанного зимой, посчитать сумму заказа. Выборка должна содержать номер заказа, сумму. */

select pd_order_details.order_id,
       sum(price * quantity) as order_sum
from pd_order_details
      join pd_products on pd_order_details.product_id = pd_products.id
      join pd_orders on pd_order_details.order_id = pd_orders.id
where (extract(month from pd_orders.delivery_date) IN (1, 2, 12))
group by order_id;

/* 6 Для каждого месяца найдите общее количество заказанных напитков, десертов и пицц.
   Выборка должна содержать год и номер месяца (один атрибут), общее количество напитков, общее количество десертов и общее количество пицц.
   Все атрибуты должны иметь имя. */

select to_char(order_date, 'YYYY-MM') as month,
       sum(case when category ilike 'Напитки' then quantity end) as drinks,
        sum(case when category ilike 'Десерты' then quantity end) as desserts,
        sum(case when category ilike 'Пицца' then quantity end) as pizzas

from pd_order_details
    join pd_orders on pd_orders.id = pd_order_details.id
    join pd_products on pd_order_details.product_id = pd_products.id
group by to_char(order_date, 'YYYY-MM')
order by month;

/* 7 Для каждого месяца найдите какой процент о общей выручки приходится на острые, вегетарианские,
   острые и вегетарианские продукты.
   Без учёта каких-либо скидок. */

select to_char(order_date, 'YYYY-MM') as month,

        trunc(sum(case when is_vegan and is_hot then quantity * price end) / sum(quantity * price) * 100, 2) as hot_and_vegan,
        trunc(sum(case when is_vegan and not is_hot then quantity * price end) / sum(quantity * price) * 100, 2) as vegan,
        trunc(sum(case when is_hot and not is_vegan then quantity * price end) / sum(quantity * price) * 100, 2) as hot

from pd_order_details
    join pd_orders on pd_orders.id = pd_order_details.id
    join pd_products on pd_order_details.product_id = pd_products.id
group by to_char(order_date, 'YYYY-MM')
order by month;
