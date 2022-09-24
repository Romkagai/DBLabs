-----------
/* 1 Список всех не пицц. Выборка должна содержать только наименование, цену и категорию товара. */

SELECT
    product_name, category, price
FROM
    pd_products
WHERE
    category NOT ILIKE 'Пицца';

-----------
/* 2 Список всех улиц и районов, в которые делались заказы. В списке не должно быть дублей.
   Выборка должна содержать только улицу и район. */

SELECT DISTINCT
    street, area
FROM
    pd_customers;
-----------
/* 3 Список всех продукты, в описании которых упоминается “Моцарелла”.
  Выборка должна содержать только наименование и описание.*/

SELECT
    product_name, description
FROM
    pd_products
WHERE
    description ILIKE '%Моцарелла%';

-----------
/*4 Список всех пицц, где для каждой подписана характеристика, является ли пицца острой или вегетарианской.
  Характеристика должны быть подписана по-русски, должен учитываться вариант выставления обоих отметок.
  Выборка должна содержать только наименование, цену и характеристику.*/

SELECT product_name, price,
        CASE WHEN is_hot AND is_vegan THEN 'Острая, Вегетарианская'
            WHEN is_hot THEN 'Острая'
            WHEN is_vegan THEN 'Вегетарианская'
            ELSE 'Нет'
        END AS characteristics
FROM
    pd_products
WHERE
    category ILIKE 'Пицца';

-----------
/* 5 Список всех сотрудников в формате: <Имя> должность “<название с маленькой буквы>”,
  работает с <месяц (имя месяца)> <год> года.*/

set lc_time = 'ru_RU';

SELECT
    name || ', должность ' || lower(post) || ', работает с ' || to_char(start_date, 'TMMonth') ||
 ' ' || extract(year from start_date) || ' года' as employees
FROM
    pd_employees;

-----------
/* 6 Список адресов покупателей, которые не указали район.
  Выборка должна представлять список адресов в формате <название улицы>, дом <номер дома> кв. <номер квартиры>. */

SELECT
    street || ', дом ' || house_number || ', кв. ' || apartment as full_address
FROM
    pd_customers WHERE (area IS NULL or area = ' ');

-----------
/* 7 Выбрать все продукты без описания в категориях десерт и напитки.
  Выборка должна содержать только наименование, цену и категорию.*/

SELECT
    product_name, price, category
FROM
    pd_products
WHERE
    (description IS NULL OR description = ' ') and
    (category ILIKE 'Десерты' OR
    category ILIKE 'Напитки');

-----------
/* 8 Список всех острых или вегетарианских пицц с базиликом ценой от 500.
  Выборка должна содержать только наименование, описание, категорию и цену.*/

SELECT
    product_name, description, category, price
FROM
    pd_products
WHERE
    (is_vegan OR is_hot) AND
    price >= 500 AND
    description ILIKE '%Базилик%';

-----------
/* 9 Список всех острых пицц стоимостью от 460 до 510, если пицц при этом ещё и вегетарианская,
   то стоимость может доходить до 560.
   Выборка должна содержать только наименование, цену и отметки об остроте и доступности для вегетарианцев.*/

SELECT
    product_name, price,
    CASE WHEN is_hot AND is_vegan THEN 'Острая, Вегетарианская'
            WHEN is_hot THEN 'Острая'
            WHEN is_vegan THEN 'Вегетарианская'
            ELSE 'Нет'
        END AS characteristics
FROM
    pd_products
WHERE
    (category ILIKE 'Пицца' and is_hot and price between 460 and 510) or
    (category ILIKE 'Пицца' and is_hot and is_vegan and price between 460 and 560);

-----------
/* 10 Для каждого продукта рассчитать, на сколько процентов можно поднять цену,
  так что бы первая цифра цены не поменялась (т.е. что бы все цены стали вида: x9, x99 и т.д).
  Выборка должна содержать только наименование, цену, новую цену,
  процент повышения цены (округлить до 3-х знаков после запятой), размер возможного повышения до копеек.
 */

SELECT
    product_name, price,

    --Берем первую цифру числа, увеличиваем на 1, умножаем её на количество разрядов этого числа и вычитаем единицу
    --Затем используем эту же формулу для нахождения процента и разницы в цене

    cast((cast(substring(cast(price as text) from 1 for 1) as numeric) + 1) *
    power(10, length(cast (floor(price) as text)) - 1) - 1 as numeric) as new_price,

    (trunc((cast((cast(substring(cast(price as text) from 1 for 1) as numeric) + 1) *
    power(10, length(cast (floor(price) as text)) - 1) - 1 as numeric) / price - 1) * 100 , 3))  as "%",

    (cast((cast(substring(cast(price as text) from 1 for 1) as numeric) + 1) *
    power(10, length(cast (floor(price) as text)) - 1) - 1 as numeric) - price) as diff_price

FROM
    pd_products;

-----------
/* 11 Список возможных цен на все продукты, если увеличить цену для острых продуктов на 1,5% , для вегетарианских на 1%, для острых и вегетарианских на 2%.
  Выбрать продукты, для которых новая цена не будет превышать 520 для пицц, 190 для сэндвич-роллов 65 для остальных.
  Выборка должна содержать только наименование, описание, цену, новую цену (до 2-х знаков после запятой),
  размер увеличения цены цену (до 2-х знаков после запятой) и отметки об остроте и доступности для вегетарианцев.
 */

SELECT
    product_name, description, price,

    trunc(price *
        CASE
            WHEN is_hot AND is_vegan THEN 1.02
            WHEN is_hot THEN 1.015
            WHEN is_vegan THEN 1.01
            ELSE 1
        END, 2) AS new_price,

    trunc(price *
        CASE
            WHEN is_hot AND is_vegan THEN 0.02
            WHEN is_hot THEN 0.015
            WHEN is_vegan THEN 0.01
            ELSE 0
        END, 2) AS add_price,

        CASE WHEN is_hot AND is_vegan THEN 'Острая, Вегетарианская'
            WHEN is_hot THEN 'Острая'
            WHEN is_vegan THEN 'Вегетарианская'
            ELSE 'Нет'
        END AS characteristics

FROM
    pd_products
WHERE
    price *

    CASE
        WHEN is_hot AND is_vegan THEN 1.02
        WHEN is_hot THEN 1.015
        WHEN is_vegan THEN 1.01
        ELSE 1
    END
                        <=
    CASE
        WHEN category = 'Пицца' THEN 520
        WHEN category = 'Сэндвич-ролл' THEN 190
        ELSE 65
    END;

-----------
/* 12 Список всех курьеров, которые выполняли заказы 1-го и 2-го января.
  Выборка должна содержать только Имя курьера и полный адрес заказа.*/

SELECT
    pd_employees.name, street || ', дом ' || house_number || ', кв. ' || apartment as full_address
FROM pd_orders
    JOIN pd_employees ON emp_id = pd_employees.id
    JOIN pd_customers ON cust_id = pd_customers.id
WHERE
    extract(month from delivery_date) = 1 AND
    (extract(day from delivery_date) = 1 OR
    extract(day from delivery_date) = 2);

-----------
/* 13 Список всех заказчиков, заказывавших пиццу в октябрьском районе в сентябре или октябре.
  Выборка должна содержать только имена покупателей без дублирования.*/

SELECT DISTINCT
    pd_customers.name
FROM pd_orders
    JOIN pd_customers ON pd_customers.id = pd_orders.cust_id
WHERE
    pd_customers.area ILIKE 'Октябрьский' AND
    (extract(month from delivery_date) = 9 OR
    extract(month from delivery_date) = 10);

-----------
/* 14 Список всех сотрудников в формате: <Имя> должность “<название с маленькой буквы>”,
  работает с <месяц (имя месяца)> <год> года, непосредственный руководитель <Имя>.*/

SELECT
    first.name || ', должность ' || lower(first.post) || ', работает с ' ||
    to_char(first.start_date, 'TMMonth') ||
    ' ' || extract(year from first.start_date) || ' года, непосредственный руководитель: ' ||
    CASE
        WHEN first.manager_id IS NULL THEN 'Отсутсвует'
        ELSE second.name END AS employees
FROM pd_employees first
    LEFT JOIN pd_employees second ON first.manager_id = second.id;

-----------
/* 15 Список всех адресов (без дублирования), которые были доставлены под руководством
  Барановой (или ей самой) зимой.
  В списке также должны отображаться: имя курьера, адрес, район (‘нет’ – если район не известен).
  Выборка должна быть отсортирована по именам курьеров.*/

SELECT DISTINCT pd_employees.name,
       street || ', дом ' || house_number || ', кв. ' || apartment as full_address,
       CASE WHEN area IS NULL THEN 'Нет' ELSE area END
FROM pd_orders
    JOIN pd_employees ON pd_orders.emp_id = pd_employees.id
    JOIN pd_customers ON pd_orders.cust_id = pd_customers.id
WHERE
    (pd_employees.manager_id = 1 OR pd_employees.id = 1) AND
    (extract(month from pd_orders.delivery_date) IN (1, 2, 12))
ORDER BY
    pd_employees.name ASC;

-----------
/* 16 Список продуктов, которые заказывали вместе с острыми или вегетарианскими пиццами в этом месяце.*/

SELECT DISTINCT
    pd_products1.product_name

FROM pd_orders

    JOIN pd_order_details as pd_order_details1 ON pd_orders.id = pd_order_details1.order_id
    JOIN pd_products as pd_products1 ON pd_order_details1.product_id = pd_products1.id

    JOIN pd_order_details as pd_order_details2 ON pd_orders.id = pd_order_details2.order_id
    JOIN pd_products as pd_products2 ON pd_order_details2.product_id = pd_products2.id

WHERE
    pd_products1.category NOT ILIKE 'Пицца' and
    (extract(month from pd_orders.order_date) = extract(month from current_date)) and
    (pd_products2.is_hot or pd_products2.is_vegan) and
    pd_products2.category ILIKE 'Пицца';