/* Question for Marketing Analysis  */

-- 1. How many transactions were completed during each marketing campaign?

SELECT
	mc.campaign_name,
	COUNT(t.transaction_id) AS Transactions
FROM marketing_campaigns mc
JOIN transactions t ON mc.product_id = t.product_id
WHERE t.purchase_date BETWEEN mc.start_date AND mc.end_date
GROUP BY mc.campaign_name;


-- 2. Which product had the highest sales quantity?

SELECT TOP 1
	sc.product_name,
	SUM(t.quantity) AS Sales
FROM sustainable_clothing sc
JOIN transactions t ON sc.product_id = t.product_id
GROUP BY sc.product_name
ORDER BY Sales DESC;

-- 3. What is the total revenue generated from each marketing campaign?

SELECT
	mc.campaign_name,
	SUM(t.quantity * sc.price) AS 'Total Revenue'
FROM marketing_campaigns mc
JOIN transactions t ON t.product_id = mc.product_id
JOIN sustainable_clothing sc ON sc.product_id = t.product_id
GROUP BY mc.campaign_name;

-- 4. What is the top-selling product category based on the total revenue generated?

SELECT TOP 1
	sc.category,
	SUM(t.quantity * sc.price) AS 'Total Revenue'
FROM transactions t
jOIN sustainable_clothing sc ON sc.product_id = t.product_id
GROUP BY sc.category
ORDER BY [Total Revenue] DESC;

-- 5. Which products had a higher quantity sold compared to the average quantity sold?

SELECT TOP 1
	sc.product_name,
	SUM(t.quantity) AS 'Quantity Sold',
	(SELECT AVG(quantity) FROM transactions) AS 'Average Quantity Sold'
FROM sustainable_clothing sc
JOIN transactions t ON t.product_id = sc.product_id
GROUP BY sc.product_name
HAVING SUM(t.quantity) > (SELECT AVG(quantity) FROM transactions)
ORDER BY [Quantity Sold] DESC,

-- 6. What is the average revenue generated per day during the marketing campaigns?

SELECT
	 [daily totals].campaign_name,
	AVG([daily revenue]) AS [Average Revenue]
FROM (
	SELECT
		mc.campaign_name,
		t.purchase_date,
		SUM(t.quantity * sc.price) AS [daily revenue]
	FROM marketing_campaigns mc
	JOIN transactions t ON mc.product_id = t.product_id
	JOIN sustainable_clothing sc ON t.product_id = sc.product_id
	WHERE t.purchase_date BETWEEN mc.start_date AND mc.end_date
	GROUP BY mc.campaign_name,t.purchase_date) AS [daily totals]
GROUP BY [daily totals].campaign_name;

-- 7. What is the percentage contribution of each product to the total revenue?

SELECT 
    sc.product_name,
    SUM(t.quantity * sc.price) AS [Product Revenue],
		(SELECT SUM(quantity * price) FROM transactions t2
		JOIN sustainable_clothing sc2 ON t2.product_id = sc2.product_id
	) AS [Total Revenue],
	(SUM(t.quantity * sc.price) / (SELECT SUM(quantity * price) FROM transactions t2 JOIN sustainable_clothing sc2 ON t2.product_id = sc2.product_id)) * 100 AS [Revenue Percentage]
FROM transactions t
JOIN sustainable_clothing sc ON t.product_id = sc.product_id
GROUP BY sc.product_name
ORDER BY [Revenue Percentage] DESC;


-- 8. Compare the average quantity sold during marketing campaigns to outside the marketing campaigns

SELECT 
    sc.product_name,
    (
        SELECT AVG(t.quantity)
        FROM transactions t
        JOIN marketing_campaigns mc ON t.product_id = mc.product_id
        WHERE t.product_id = sc.product_id AND t.purchase_date BETWEEN mc.start_date AND mc.end_date
    ) AS [Avg Qty During Campaing],
    (
        SELECT AVG(t.quantity)
        FROM transactions t
        LEFT JOIN marketing_campaigns mc ON t.product_id = mc.product_id
        WHERE t.product_id = sc.product_id AND (t.purchase_date NOT BETWEEN mc.start_date AND mc.end_date OR mc.campaign_id IS NULL)
    ) AS [Avg Qty Outside Campaign]
FROM sustainable_clothing sc
GROUP BY sc.product_name,sc.product_id;


-- 9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns

SELECT
    sc.product_name,
    SUM(CASE WHEN t.purchase_date BETWEEN mc.start_date AND mc.end_date THEN t.quantity * sc.price
        ELSE 0
    END) AS [Revenue During Campaign],
    SUM(CASE WHEN t.purchase_date NOT BETWEEN mc.start_date AND mc.end_date OR mc.campaign_id IS NULL THEN t.quantity * sc.price
        ELSE 0
    END) AS [Revenue Outside Campaign]
FROM transactions t
LEFT JOIN marketing_campaigns mc ON t.product_id = mc.product_id
JOIN sustainable_clothing sc ON t.product_id = sc.product_id
GROUP BY sc.product_name;

-- 10. Rank the products by their average daily quantity sold

SELECT
    sc.product_name,
    SUM(t.quantity) AS [Total Quantity],
    COUNT(DISTINCT t.purchase_date) AS [Selling Days],
    SUM(t.quantity) / COUNT(DISTINCT t.purchase_date) AS [Avg Daily Qty Sold],
    RANK() OVER (ORDER BY SUM(t.quantity) / COUNT(DISTINCT t.purchase_date) DESC) AS [Rank]
FROM transactions t
JOIN sustainable_clothing sc ON t.product_id = sc.product_id
GROUP BY sc.product_name
ORDER BY [Avg Daily Qty Sold] DESC;
