--  What is the average number of users successfully sharing food from each store per
-- business?

SELECT 
	b.id as busniess_id,
	b.industry,
    s.id as site_id,
    COUNT(DISTINCT l.user_id) AS total_users_sharing_food,
    ROUND(AVG(COUNT(DISTINCT l.user_id)) OVER (PARTITION BY b.id) ,2) AS avg_users_sharing_food_per_business
FROM 
    businesses b
INNER JOIN 
    sites s ON b.id = s.business_id
INNER JOIN 
    listings l ON s.id = l.site_id
GROUP BY 
    b.id, b.industry, s.id; 
