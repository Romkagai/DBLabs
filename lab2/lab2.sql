-----------
/* 1 Найти среднюю стоимость пиццы с точность до второго знака. Выборка должна содержать только одно число. */

select trunc(avg(price), 2) as avg_pizza_price
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
        round(max(price) / trunc(avg(price), 2) * 100 - 100, 2) as max_price_deviation,
        round(100 - min(price) / trunc(avg(price), 2) * 100 ,2) as min_price_deviation
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
group by order_id
order by order_id asc;

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
group by month
order by month;


/* 7 Для каждого месяца найдите какой процент о общей выручки приходится на острые, вегетарианские,
   острые и вегетарианские продукты.
   Без учёта каких-либо скидок. */

select to_char(order_date, 'YYYY-MM') as month,

        round(sum(case when is_vegan and is_hot then quantity * price end) / sum(quantity * price) * 100, 2) as hot_and_vegan,
        round(sum(case when is_vegan and not is_hot then quantity * price end) / sum(quantity * price) * 100, 2) as vegan,
        round(sum(case when is_hot and not is_vegan then quantity * price end) / sum(quantity * price) * 100, 2) as hot

from pd_order_details
    join pd_orders on pd_order_details.order_id = pd_orders.id
    join pd_products on pd_order_details.product_id = pd_products.id

group by month
order by month;

/* 8 Выбрать осенние заказы, в которых общее количество заказанных продуктов не больше 5.*/

select order_id

from pd_order_details
    join pd_orders on pd_order_details.order_id = pd_orders.id

where (extract(month from pd_orders.order_date) IN (9, 10, 11))
group by order_id
having sum(quantity) <= 5;

/* 9 Курьеров, которые чаще доставляли заказы в Кировский район, чем в Советский, за два последних месяца.*/

with EmployeesTable as(
    select emp_id,
           count(case when area ilike 'кировский' then emp_id end) as KirNumber,
           count(case when area ilike 'советский' then emp_id end) as SovNumber
    from pd_orders
        join pd_customers on pd_orders.cust_id = pd_customers.id
        join pd_employees on pd_orders.emp_id = pd_employees.id
    where pd_orders.order_date > (current_timestamp - interval '2 month') and post ilike 'курьер'
    group by emp_id
)

select name
from EmployeesTable
    join pd_employees on pd_employees.id = EmployeesTable.emp_id
where KirNumber > SovNumber;

/* 10 Напишите запрос, выводящий следующие данные:
   номер заказа, имя курьера, имя заказчика (одной строкой), общая стоимость заказа, срок доставки,
   отметка о том был ли заказа доставлен вовремя. */

select distinct pd_orders.id as order_id,
                pd_employees.name as emp_name,
                pd_customers.name as cust_name,
                sum(price * pd_order_details.quantity) over (partition by pd_orders.id) as order_cost,
                to_char(exec_date - pd_orders.order_date, 'DD дней HH24 часов MI минут') as delivery_time,
                case when (exec_date <= pd_orders.delivery_date) then 'Вовремя' else 'Задержка' end as order_delay

from pd_orders
    join pd_order_details on pd_order_details.order_id = pd_orders.id
    join pd_employees on pd_employees.id = pd_orders.emp_id
    join pd_customers on pd_customers.id = pd_orders.cust_id
    join pd_products on pd_products.id = pd_order_details.product_id;

/* 11 Для каждого заказа, в котором есть хотя бы 1 острая пицца посчитать стоимость напитков. */

with DrinksCost as(
    select pd_orders.id, sum(price * quantity) as order_drink_cost
    from pd_orders
        join pd_order_details on pd_order_details.order_id = pd_orders.id
        join pd_products on pd_products.id = pd_order_details.product_id
    where category ilike 'напитки'
    group by pd_orders.id
    )

, OrdersWithHotPizzas as(
    select pd_order_details.order_id
    from pd_order_details
        join pd_products on pd_order_details.product_id = pd_products.id
    where category ilike 'пицца' and is_hot
    group by pd_order_details.order_id
    )

select OrdersWithHotPizzas.order_id, sum(DrinksCost.order_drink_cost) as sum_for_drinks
from OrdersWithHotPizzas
    join DrinksCost on OrdersWithHotPizzas.order_id = DrinksCost.id
group by OrdersWithHotPizzas.order_id
order by order_id;

/* 12 Найти курьера, выполнившего вовремя наибольшее число заказов (без использования limit). */

with OrderNumber as(
        select emp_id, count(emp_id) as number_of_orders
        from pd_orders
        where exec_date <= pd_orders.delivery_date
        group by emp_id
)

select emp_id, name
from OrderNumber
    join pd_employees on pd_employees.id = OrderNumber.emp_id
where
    number_of_orders = (select(max(number_of_orders)) from OrderNumber) and
    post ilike 'курьер';


/* 13 Определить район, в который чаще всего заказывали напитки (без использования limit). */
/* P.S. Учитывается общее количество напитков в район*/

with orders_with_drinks as(
    select pd_orders.id, sum(quantity), pd_orders.cust_id
    from pd_order_details
        join pd_products on pd_products.id = pd_order_details.product_id
        join pd_orders on pd_orders.id = pd_order_details.order_id
    where category ilike 'напитки'
    group by pd_orders.id
),
     areas_with_max_drinks as(
     select area, count(area) as number_of_orders
            from orders_with_drinks
                join pd_customers on orders_with_drinks.cust_id = pd_customers.id
            where area is not null
            group by area
            )
select area
from areas_with_max_drinks
where number_of_orders = (select(max(number_of_orders)) from areas_with_max_drinks);

/* Определить район, в который чаще всего заказывали только напитки и десерты без пицц (без использования limit).
    P.S. В заказе не учитывается количество продуктов, только наличие в заказе напитков и десертов без пицц
    ddnp - drinks desserts not pizzas*/

with orders_with_ddnp as(
    select pd_orders.id, cust_id
        from pd_orders

            join pd_order_details pod1 on pd_orders.id = pod1.order_id
            join pd_products p1 on pod1.product_id = p1.id

            join pd_order_details pod2 on pd_orders.id = pod2.order_id
            join pd_products p2 on pod2.product_id = p2.id

            join pd_order_details pod3 on pd_orders.id = pod3.order_id
            join pd_products p3 on pod3.product_id = p3.id

        where p1.category ilike 'напитки' and p2.category ilike 'десерты' and p3.category not ilike 'пицца'
        group by pd_orders.id
),
     areas_with_ddnp as(
     select area, count(area) as number_of_orders
            from orders_with_ddnp
                join pd_customers on orders_with_ddnp.cust_id = pd_customers.id
            where area is not null
            group by area
            )
select area
from areas_with_ddnp
where number_of_orders = (select(max(number_of_orders)) from areas_with_ddnp)

