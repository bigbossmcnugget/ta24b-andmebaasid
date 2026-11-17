-- II Sakila päringud   Jegor Onoprijuk, TA-24B
USE sakila;
-- 1. Mitu filmi, näitlejat, klienti ja renti on andmebaasis?
SELECT (SELECT COUNT(*) FROM film) filme, (SELECT COUNT(*) FROM actor) naitlejaid, (SELECT COUNT(*) FROM customer) kliente, (SELECT COUNT(*) FROM rental) rente;
-- 2. Viis pikimat filmi
SELECT title, length FROM film ORDER BY length DESC, title LIMIT 5;
-- 3. Filmide arv kategooriate kaupa
SELECT c.name AS kategooria, COUNT(*) AS filme FROM film_category fc JOIN category c USING (category_id) GROUP BY c.category_id ORDER BY filme DESC, kategooria;
-- 4. Kümme enim filmides esinenud näitlejat
SELECT a.first_name, a.last_name, COUNT(*) AS filme FROM actor a JOIN film_actor fa USING (actor_id) GROUP BY a.actor_id ORDER BY filme DESC, a.last_name LIMIT 10;
-- 5. Viis kõige enam renditud filmi
SELECT f.title, COUNT(*) AS rente FROM rental r JOIN inventory i USING (inventory_id) JOIN film f USING (film_id) GROUP BY f.film_id ORDER BY rente DESC, f.title LIMIT 5;
-- 6. Viis klienti, kes on kõige rohkem maksnud
SELECT c.first_name, c.last_name, ROUND(SUM(p.amount),2) AS kokku FROM payment p JOIN customer c USING (customer_id) GROUP BY c.customer_id ORDER BY kokku DESC LIMIT 5;
-- 7. Tulu kauplustes
SELECT s.store_id, ROUND(SUM(p.amount),2) AS tulu FROM payment p JOIN staff s USING (staff_id) GROUP BY s.store_id;
-- 8. Mitu filmi on igas reitingus
SELECT rating, COUNT(*) AS filme FROM film GROUP BY rating ORDER BY filme DESC;
-- 9. Rendiaegu ületanud (tagastamata) rendid
SELECT COUNT(*) AS tagastamata FROM rental WHERE return_date IS NULL;
-- 10. Filmid, mida ühelgi inventari ühikul pole
SELECT COUNT(*) AS filme_ilma_inventarita FROM film f LEFT JOIN inventory i USING (film_id) WHERE i.inventory_id IS NULL;
