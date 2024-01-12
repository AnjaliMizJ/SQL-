-- Which are the top 5 sites each month based on the number of items added?
SELECT 
    month_year,
    site_id,
    items_added,
    site_rank
FROM (
    SELECT 
        CONCAT(YEAR(date), '-', LPAD(MONTH(date), 2, '0')) AS month_year,
        site_id,
        SUM(items) AS items_added,
        ROW_NUMBER() OVER (PARTITION BY CONCAT(YEAR(date), '-', LPAD(MONTH(date), 2, '0')) ORDER BY SUM(items) DESC) AS site_rank
    FROM 
        listings
    GROUP BY 
        CONCAT(YEAR(date), '-', LPAD(MONTH(date), 2, '0')),
        site_id
) ranked_listings
WHERE 
    site_rank <= 5
ORDER BY 
    month_year, 
    site_rank;
