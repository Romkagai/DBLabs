-----------
/* Список всех не пицц. Выборка должна содержать только наименование, цену и категорию товара. */

SELECT product_name, category, price
FROM pd_products
WHERE category <> 'Пицца';

-----------
/* Список всех улиц и районов, в которые делались заказы. В списке не должно быть дублей.
   Выборка должна содержать только улицу и район. */

SELECT DISTINCT street, area
FROM pd_customers;
-----------
/*Список всех продукты, в описании которых упоминается “Моцарелла”.
  Выборка должна содержать только наименование и описание.*/

SELECT product_name, description
FROM pd_products
WHERE description ILIKE '%Моцарелла%';
-----------
/*Список всех пицц, где для каждой подписана характеристика, является ли пицца острой или вегетарианской.
  Характеристика должны быть подписана по-русски, должен учитываться вариант выставления обоих отметок.
  Выборка должна содержать только наименование, цену и характеристику.*/

SELECT product_name, price,
        CASE WHEN is_hot AND is_vegan THEN 'Острая, Вегетарианская'
            WHEN is_hot THEN 'Острая'
            WHEN is_vegan THEN 'Вегетарианская'
        END AS characteristics
FROM pd_products WHERE is_vegan OR is_hot;



-----------
/*Список всех сотрудников в формате: <Имя> должность “<название с маленькой буквы>”,
  работает с <месяц (имя месяца)> <год> года.*/

SELECT name || ', должность ' || lower(post) || ', работает с ' || start_date as data1
from pd_employees;

-----------
/*Список адресов покупателей, которые не указали район.
  Выборка должна представлять список адресов в формате <название улицы>, дом <номер дома> кв. <номер квартиры>. */

SELECT street || ', дом ' || house_number || ', кв. ' || apartment as full_address
FROM pd_customers WHERE area IS NOT NULL;

-----------
/*Выбрать все продукты без описания в категориях десерт и напитки.
  Выборка должна содержать только наименование, цену и категорию.*/

SELECT product_name, price, category
FROM pd_products WHERE
                     description IS NULL AND
                     (category ILIKE 'Десерты' OR
                     category ILIKE 'Напитки');

-----------
/*Список всех острых или вегетарианских пицц с базиликом ценой от 500.
  Выборка должна содержать только наименование, описание, категорию и цену.*/


SELECT product_name, description, category, price
FROM pd_products WHERE
                     (is_vegan OR is_hot) AND
                     price >= 500 AND
                     description ILIKE '%Базилик%';

-----------
/*Для каждого продукта рассчитать, на сколько процентов можно поднять цену,
  так что бы первая цифра цены не поменялась (т.е. что бы все цены стали вида: x9, x99 и т.д).
  Выборка должна содержать только наименование, цену, новую цену,
  процент повышения цены (округлить до 3-х знаков после запятой), размер возможного повышения до копеек.
 */

SELECT product_name, price,

    cast((cast(substring(cast(price as text) from 1 for 1) as numeric) + 1) *
    power(10, length(cast (floor(price) as text)) - 1) - 1 as numeric) as new_price,


    trunc(cast((cast(substring(cast(price as text) from 1 for 1) as numeric) + 1) *
    power(10, length(cast (floor(price) as text)) - 1) - 1 as numeric) / price, 3) as "%",

    (cast((cast(substring(cast(price as text) from 1 for 1) as numeric) + 1) *
    power(10, length(cast (floor(price) as text)) - 1) - 1 as numeric) + 0.99) as prob_price

FROM pd_products;

-----------
/*Список возможных цен на все продукты, если увеличить цену для острых продуктов на 1,5% , для вегетарианских на 1%, для острых и вегетарианских на 2%.
  Выбрать продукты, для которых новая цена не будет превышать 520 для пицц, 190 для сэндвич-роллов 65 для остальных.
  Выборка должна содержать только наименование, описание, цену, новую цену (до 2-х знаков после запятой),
  размер увеличения цены цену (до 2-х знаков после запятой) и отметки об остроте и доступности для вегетарианцев.
 */

SELECT product_name, description, price,
       trunc(price *
             CASE
                 WHEN is_hot AND is_vegan THEN 1.02
                 WHEN is_hot THEN 1.015
                 WHEN is_vegan THEN 1.01
             END, 2) AS new_price,
        is_hot, is_vegan

FROM pd_products
    WHERE price *
    CASE
        WHEN is_hot AND is_vegan THEN 1.02
        WHEN is_hot THEN 1.015
        WHEN is_vegan THEN 1.01
    END
                        <=
    CASE
        WHEN category = 'Пицца' THEN 520
        WHEN category = 'Сэндвич-ролл' THEN 190
        ELSE 65
    END

-----------
/*Список всех курьеров, которые выполняли заказы 1-го и 2-го января.
  Выборка должна содержать только Имя курьера и полный адрес заказа.*/

SELECT pd_employees.name, street || ', дом ' || house_number || ', кв. ' || apartment as full_address
FROM pd_orders
    JOIN pd_employees ON emp_id = pd_employees.id
    JOIN pd_customers ON cust_id = pd_customers.id
WHERE
    extract(month from delivery_date) = 1 AND
    (extract(day from delivery_date) = 1 OR
    extract(day from delivery_date) = 2)

-----------
/*Список всех заказчиков, заказывавших пиццу в октябрьском районе в сентябре или октябре.
  Выборка должна содержать только имена покупателей без дублирования.*/

SELECT DISTINCT pd_customers.name
FROM pd_orders
    JOIN pd_customers ON pd_customers.id = pd_orders.cust_id
WHERE
    pd_customers.area ILIKE 'Октябрьский' AND
    (extract(month from delivery_date) = 9 OR
    extract(month from delivery_date) = 10)

-----------
/* ТЕСТ ИЗМЕНЕНИЯ N2 2e2 e2 e2 2 22e 2 e2


