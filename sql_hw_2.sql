-- 3.1. Посчитать количество заказов за все время.
-- Смотри таблицу orders. Вывод: количество заказов.

SELECT COUNT(*) AS "количество заказов"
FROM orders;

-- 3.2. Посчитать сумму денег по всем заказам за все время (учитывая скидки).
-- Смотри таблицу order_details. Вывод: id заказа, итоговый чек (сумма стоимостей всех  продуктов со скидкой)

WITH order_with_absolut AS (
	SELECT order_id,
		CAST(SUM(unit_price * quantity) AS numeric(10,	2)) AS count_sold,
		CAST(SUM(unit_price * quantity * discount) AS numeric(10, 	2)) AS abs_discount
	FROM order_details
	GROUP BY order_id)
SELECT order_id, count_sold "Сумма товара", abs_discount "Скидка",
	CAST(SUM(count_sold - abs_discount) AS numeric(10,	2)) "Сумма заказа"
FROM order_with_absolut
GROUP BY order_id, count_sold, abs_discount
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
	    CAST(SUM(unit_price * quantity) AS numeric(10, 2)) AS sum_orders
	FROM orders
	JOIN order_details USING(order_id)
    GROUP BY employee_id
), employee_fio AS (
	SELECT employee_id, concat(lASt_name, ' ', first_name) AS fio
	FROM employees
)
SELECT t2.fio "ФИО", t1.SUM_orders "Сумма всех заказов"
FROM orders_SUM t1
LEFT JOIN employee_fio t2 USING(employee_id)
ORDER BY t1.SUM_orders DESC;

-- 3.5. Показать перечень товаров от самых продаваемых до самых непродаваемых (в штуках).
-- Вывести наименование продукта и количество проданных штук.

WITH orders_products AS (
	SELECT product_id, SUM(quantity) AS quantity_prod
	FROM order_details
	GROUP BY product_id
	ORDER BY product_id
)
SELECT t2.product_name "Наименование продукта", quantity_prod "Продано (шт)"
FROM orders_products t1
LEFT JOIN products t2 USING(product_id)
ORDER BY quantity_prod DESC;
