--Вывести к каждому самолету класс обслуживания и количество мест этого класса.
SELECT a.model, s.fare_conditions, COUNT(s.seat_no) AS seats_count
FROM aircrafts a
INNER JOIN seats s
    ON a.aircraft_code = s.aircraft_code
GROUP BY a.model, s.fare_conditions
ORDER BY a.model, s.fare_conditions;


--Найти 3 самых вместительных самолета (модель + кол-во мест).
SELECT a.model, COUNT(s.seat_no) AS seats_count
FROM aircrafts a
INNER JOIN seats s
    ON a.aircraft_code = s.aircraft_code
GROUP BY a.model
ORDER BY COUNT(s.seat_no) DESC LIMIT 3;


--Вывести код, модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам.
SELECT a.aircraft_code, a.model, s.seat_no
FROM aircrafts a
INNER JOIN seats s
    ON a.aircraft_code = s.aircraft_code
WHERE a.model = 'Аэробус A321-200'
    AND s.fare_conditions != 'Economy'
ORDER BY s.seat_no ASC;


--Вывести города в которых больше 1 аэропорта (код аэропорта, аэропорт, город).
SELECT a.airport_code, a.airport_name, a.city
FROM airports a
WHERE a.city IN (SELECT a2.city
                 FROM airports a2
                 GROUP BY a2.city
                 HAVING COUNT(a2.city) > 1);


--Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация.
SELECT f.flight_no
FROM flights f
INNER JOIN airports a
    ON a.airport_code = f.departure_airport
INNER JOIN airports a2
    ON a2.airport_code = f.arrival_airport
WHERE a.city = 'Екатеринбург'
    AND a2.city = 'Москва'
    AND f.status IN ('On Time', 'Delayed');


--Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе).
SELECT 'min ticket cost' AS cost, MIN(tf.amount)
FROM ticket_flights tf
UNION
SELECT 'max ticket cost', MAX(tf2.amount)
FROM ticket_flights tf2;


--Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email , phone.
CREATE TABLE IF NOT EXISTS customers
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(30),
    last_name  VARCHAR(30),
    email      VARCHAR(40),
    phone      VARCHAR(20)
);
--Добавить ограничения на поля (constraints).
ALTER TABLE customers ALTER COLUMN first_name SET NOT NULL;
ALTER TABLE customers ALTER COLUMN last_name SET NOT NULL;
ALTER TABLE customers ALTER COLUMN email SET NOT NULL;
ALTER TABLE customers ALTER COLUMN phone SET NOT NULL;
ALTER TABLE customers ADD CONSTRAINT unique_customer UNIQUE (first_name, last_name, email, phone);


--Написать DDL таблицы Orders, должен быть id, customerId, quantity.
CREATE TABLE IF NOT EXISTS orders
(
    id          SERIAL PRIMARY KEY,
    customer_id BIGINT,
    quantity    INT
);
--Должен быть внешний ключ на таблицу customers + ограничения.
ALTER TABLE orders ALTER COLUMN customer_id SET NOT NULL;
ALTER TABLE orders ALTER COLUMN quantity SET NOT NULL;
ALTER TABLE orders ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers (id);


--Написать 5 insert в эти таблицы.
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Иван', 'Иванов', 'ivan@gmail.com', '1111111111'),
       ('Петр', 'Петров', 'petr@gmail.com', '2222222222'),
       ('Сидр', 'Сидоров', 'sidr@gmail.com', '3333333333'),
       ('Гаврюша', 'Гаврилов', 'gavr@gmail.com', '4444444444'),
       ('Александр', 'Александров', 'alex@gmail.com', '5555555555');
INSERT INTO orders (customer_id, quantity)
VALUES (1, 3),
       (2, 5),
       (2, 4),
       (3, 1),
       (4, 22);
/*
  Еще один повторный INSERT для пояснения ограничения unique_customer.
  При повторной попытке добавления того же покупателя, сработает ограничение (ошибка).
*/
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Иван', 'Иванов', 'ivan@gmail.com', '1111111111');


--Удалить таблицы.
/* При наличии зависимостей первой удаляется зависимая таблица. */
DROP TABLE orders;
DROP TABLE customers;
/* С использованием DROP CASCADE - небезопасно, возможна потеря данных. */
DROP TABLE customers CASCADE;
DROP TABLE orders CASCADE;


--Написать свой кастомный запрос (rus + sql).
/*
  Количество перелетов, общая выручка и средняя стоимость билетов по городам отправления
  (отсортировано по количеству перелетов и средней стоимости билета).
*/
SELECT a.city,
    COUNT(DISTINCT f.flight_id) AS flights_count,
    SUM(tf.amount) AS total_amount,
    ROUND(SUM(tf.amount) / COUNT(tf.ticket_no), 2) AS avg_ticket_cost
FROM flights f
INNER JOIN airports a
    ON f.departure_airport = a.airport_code
LEFT JOIN ticket_flights tf --Были рейсы, на которые не было продано ни одного билета
    ON f.flight_id = tf.flight_id
WHERE f.status != 'Cancelled'
GROUP BY a.city
ORDER BY COUNT (f.flight_id) DESC, SUM (tf.amount) / COUNT (tf.ticket_no) DESC;