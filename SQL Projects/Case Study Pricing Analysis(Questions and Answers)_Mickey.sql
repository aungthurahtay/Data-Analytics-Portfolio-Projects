--- 1. How many pubs are located in each country??

SELECT 
	country,
	COUNT(pub_id) as 'Number of Pubs'
FROM pubs
GROUP BY country;

---2. What is the total sales amount for each pub, including the beverage price and quantity sold?

SELECT
	p.pub_name,
	SUM(b.price_per_unit * s.quantity) as 'Total Sales amount for each pub'
FROM sales s
JOIN beverages b ON s.beverage_id = b.beverage_id
JOIN pubs p ON p.pub_id = s.pub_id
GROUP BY p.pub_name;

---3. Which pub has the highest average rating?

SELECT TOP 1
	p.pub_name, 
	AVG(r.rating) AS 'Average Rating'
FROM pubs p
JOIN ratings r ON r.pub_id = p.pub_id
GROUP BY p.pub_name
ORDER BY AVG(r.rating) DESC;

---4. What are the top 5 beverages by sales quantity across all pubs?

SELECT TOP 5
	b.beverage_name,
	SUM(s.quantity) AS 'Sales Quantity',
	ROW_NUMBER() OVER(ORDER BY SUM(s.quantity) DESC) AS 'RANK'
FROM sales s
JOIN beverages b ON b.beverage_id = s.beverage_id
GROUP BY b.beverage_name;

---5. How many sales transactions occurred on each date?

SELECT
		transaction_date,
		COUNT(sale_id) AS 'Sales Transaction on each date'
FROM sales
GROUP BY transaction_date;


---6. Find the name of someone that had cocktails and which pub they had it in.

SELECT
	r.customer_name,
	p.pub_name
FROM ratings r
JOIN pubs p ON p.pub_id = r.pub_id
JOIN sales s ON s.pub_id = p.pub_id
JOIN beverages b ON b.beverage_id = s.beverage_id
WHERE b.category = 'Cocktail';

---7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?

SELECT
	category,
	AVG(price_per_unit) AS 'Average Price Per Unit'
FROM beverages
WHERE category != 'Spirit'
GROUP BY category;

---8. Which pubs have a rating higher than the average rating of all pubs?

SELECT 
	pub_name,
	r.rating,
	ar.[Average Rating]
FROM pubs p
JOIN (
	SELECT 
		pub_id,
		AVG(rating) AS 'Average Rating'
	FROM ratings
	GROUP BY pub_id ) ar ON p.pub_id = ar.pub_id
JOIN ratings r ON r.pub_id = p.pub_id
WHERE r.rating > ar.[Average Rating];

---9. What is the running total of sales amount for each pub, ordered by the transaction date?

SELECT
	s.transaction_date,
	p.pub_name,
	SUM(b.price_per_unit * s.quantity) OVER(PARTITION BY p.pub_name ORDER BY s.transaction_date) as 'Runing Total Sales amount for each pub'
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
JOIN beverages b ON s.beverage_id = b.beverage_id
GROUP BY p.pub_name, s.transaction_date, b.price_per_unit, s.quantity
ORDER BY s.transaction_date;

---10. For each country, what is the average price per unit of beverages in each category, and what is the overall average price per unit of beverages across all categories?

SELECT
	p.country,
	b.category,
	AVG(b.price_per_unit) AS 'Average Price Per Unit in Each Category',
	(SELECT
		AVG(price_per_unit)
	FROM beverages) AS 'Overall Average Price'
FROM beverages b 
JOIN sales s ON s.beverage_id = b.beverage_id
JOIN pubs p ON p.pub_id = s.pub_id
GROUP BY p.country, b.category
ORDER BY p.country;

--- 11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?

SELECT
	p.pub_name,
	b.category,
	SUM(b.price_per_unit * s.quantity) AS 'Category Sales Amount',
	SUM(SUM(b.price_per_unit * s.quantity)) OVER (PARTITION BY p.pub_id) AS 'Overall Sales Amount',
	(SUM(b.price_per_unit * s.quantity) / SUM(SUM(b.price_per_unit * s.quantity)) OVER (PARTITION BY p.pub_id) ) * 100 AS 'Percentage Contribution' 
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
JOIN beverages b ON s.beverage_id = b.beverage_id
GROUP BY p.pub_name, b.price_per_unit, s.quantity, b.category, p.pub_id;

