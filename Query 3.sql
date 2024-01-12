--  If each business is charged per day with listings, which sites have been the most
-- profitable over the last 3 months?

select site_id, round(items_last3months * businesses.cost_per_unit,2) as profit_in_last_3months
from (
	select site_id, sum(items) as items_last3months
	from (
			select site_id, date, items,  date_col.last_3months
			from listings
			cross join (select  date_sub(max(date), Interval 3 month) as last_3months  from listings) date_col
			where date >= date_col.last_3months
		) tmp1
	group by site_id
) tmp
join sites on tmp.site_id=sites.id
join businesses on sites.business_id = businesses.id
order by profit_in_last_3months desc;
