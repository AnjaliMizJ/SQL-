-- Businesses target Olio based on the percent of listings shared. If the percent of
-- listings shared drops below 65% the site is at risk of leaving Olio. Which sites are
-- currently at risk and how has this changed over timesss
SELECT
    s.id AS site_id, s.business_id,
    COUNT(l.id) AS total_listings,
    COUNT(ls.id) AS successful_listings,
    ROUND((COUNT(ls.id) * 100.0 / NULLIF(COUNT(l.id), 0)),2) AS percent_listings_shared
FROM
    sites s
LEFT JOIN
    listings l ON s.id = l.site_id
LEFT JOIN
    listing_success ls ON l.id = ls.id
GROUP BY
    s.id, s.business_id
HAVING
    (COUNT(ls.id) * 100.0 / NULLIF(COUNT(l.id), 0)) < 65
    OR (COUNT(ls.id) = 0 )  -- Condition: percent_listings_shared IS NULL 
ORDER BY
    percent_listings_shared;
