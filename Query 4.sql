-- A site (or business) is churned on a date if it has not had food listed in the previous
-- 28 days. What is the churn rate of sites by industry over time?
SELECT 
    b.industry,
    COUNT(CASE WHEN l.latest_listing_date < DATE_SUB(NOW(), INTERVAL 28 DAY) THEN 1 ELSE NULL END) AS churned_sites,
    COUNT(*) AS total_active_sites,
    (COUNT(CASE WHEN l.latest_listing_date < DATE_SUB(NOW(), INTERVAL 28 DAY) THEN 1 ELSE NULL END) / COUNT(*)) * 100 AS churn_rate
FROM 
    businesses b
INNER JOIN 
    sites s ON b.id = s.business_id
LEFT JOIN 
    (
        SELECT 
            site_id,
            MAX(date) AS latest_listing_date
        FROM 
            listings 
        GROUP BY 
            site_id
    ) l ON s.id = l.site_id
WHERE 
    s.live_date <= NOW()-- Consider only active sites as of current date
GROUP BY 
    b.industry;
