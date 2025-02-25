-- 3.1. Посчитать количество заказов за все время.
-- Смотри таблицу orders. Вывод: количество заказов.

SELECT COUNT(*) AS "количество заказов"
FROM orders;

-- 3.2. Посчитать сумму денег по всем заказам за все время (учитывая скидки).
-- Смотри таблицу order_details. Вывод: id заказа, итоговый чек (сумма стоимостей всех  продуктов со скидкой)

SELECT order_id AS "id заказа",
    CAST(SUM((unit_price * quantity) * (1 - discount)) AS numeric(10, 2)) AS "итоговый чек"
FROM order_details
GROUP BY order_id
ORDER BY order_id;

-- 3.3. Показать сколько сотрудников работает в каждом городе.
-- Смотри таблицу employee. Вывод: наименование города и количество сотрудников

SELECT city "Город", COUNT(*) "Количество"
FROM employees
GROUP BY city
ORDER BY city;

-- 3.4. Показать фио сотрудника (одна колонка) и сумму всех его заказов

WITH orders_sum AS (
	SELECT employee_id,
	    CAST(SUM((unit_price * quantity) * (1 - discount)) AS numeric(10, 2)) AS sum_orders_discount
	FROM orders
	JOIN order_details USING(order_id)
    GROUP BY employee_id
)

SELECT concat(t2.last_name, ' ', t2.first_name) "ФИО", sum_orders_discount "Сумма всех заказов"
FROM orders_sum t1
    LEFT JOIN employees t2 t2.mployee_id = t1.mployee_id
ORDER BY t1.sum_orders_discount DESC;

-- 3.5. Показать перечень товаров от самых продаваемых до самых непродаваемых (в штуках).
-- Вывести наименование продукта и количество проданных штук.

WITH orders_products AS (
	SELECT product_id, SUM(quantity) AS quantity_prod
	FROM order_details
	GROUP BY product_id
)
SELECT t2.product_name "Наименование продукта", quantity_prod "Продано (шт)"
FROM orders_products t1
    JOIN products t2 t1.product_id = t2.product_id
ORDER BY quantity_prod DESC;