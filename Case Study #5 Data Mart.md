**DATA MART**

**Case Study Questions**
The following case study questions require some data cleaning steps before we start to unpack Danny’s key business questions in more depth.

**1. Data Cleansing Steps**
In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

Convert the week_date to a DATE format

Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

Add a month_number with the calendar month for each week_date value as the 3rd column

Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

segment	age_band
1	Young Adults
2	Middle Aged
3 or 4	Retirees
Add a new demographic column using the following mapping for the first letter in the segment values:
segment	demographic
C	Couples
F	Families
Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

  	drop table if exists clean_weekly_sales;
	create table clean_weekly_sales
	(
		week_date date,
		week_number int,
		month_number int,
		calender_year int,
		region varchar(50),
		platform varchar(50),
		segment varchar(50),
		age_band varchar(50),
		demographic varchar(50),
		transactions int,
		sales int,
		avg_transaction float
		);


	insert into clean_weekly_sales
	(week_date, week_number, month_number, calender_year, region,
		platform, segment, age_band, demographic, transactions,sales,avg_transaction
	)
	select 
		TO_DATE( week_date,'YY/MM/DD') as week_date,
		EXTRACT(WEEK FROM TO_DATE( week_date,'YY-MM-DD')) as  week_number,
		EXTRACT(MONTH FROM TO_DATE( week_date,'YY-MM-DD'))  as  month_number,
		EXTRACT(year FROM TO_DATE( week_date,'YY-MM-DD'))  as  calender_year, 
		region, platform, segment, 
		case 
			when right (segment,1) = '1' then 'Young Adults'
			when right (segment,1) = '2' then 'Middle Aged'
			when right (segment,1) in ('3','4') then 'Retirees'
				else 'Unknown' end as age_band,
		case
			when left(segment, 1) = 'C' then 'Couples'
			when left(segment, 1) = 'F' then 'Families'
				else 'Unknown' end as demographic, 
 		transactions,sales,
		round(sales/transactions,2) as avg_transaction
		from data_mart.weekly_sales;

	select * from clean_weekly_sales;


**1. What day of the week is used for each week_date value?**


	select TO_CHAR(week_date, 'Day') AS week_day from data_mart.clean_weekly_sales;

**2. What range of week numbers are missing from the dataset?**

	WITH week_sequence AS (
    		SELECT generate_series(MIN(week_number), MAX(week_number)) AS week_number
    		FROM data_mart.clean_weekly_sales
		)
	SELECT ws.week_number
		FROM week_sequence ws
	LEFT JOIN data_mart.clean_weekly_sales w ON ws.week_number = w.week_number
	WHERE w.week_number IS NULL
	ORDER BY ws.week_number;


**3. How many total transactions were there for each year in the dataset?**


 	WITH trans_count AS (
    		SELECT calender_year AS year,
  			COUNT(transactions) AS transaction_count
    			FROM data_mart.clean_weekly_sales 
  			GROUP BY calender_year
  			ORDER BY calender_year
		)
	SELECT * FROM trans_count;

**4. What is the total sales for each region for each month?**

	WITH total_sales AS (
    		SELECT TO_CHAR(week_date, 'Month') AS month,
  			region AS region,
  			SUM(sales) AS total_sales
    		FROM data_mart.clean_weekly_sales 
  		GROUP BY TO_CHAR(week_date, 'Month'), region
  		ORDER BY TO_CHAR(week_date, 'Month')
		)
	SELECT * FROM total_sales;

 **5. What is the total count of transactions for each platform?**

 	WITH transaction AS (
    	SELECT 
	  	platform AS platform,
	  	count(sales) AS count_of_transaction
    	FROM data_mart.clean_weekly_sales 
  	GROUP BY platform
	)
	SELECT * FROM transaction;

 **6.What is the percentage of sales for Retail vs Shopify for each month?**

 	WITH transaction AS (
    		SELECT calender_year AS year, TO_char(week_date, 'MONTH') AS month,
  			SUM(CASE WHEN platform = 'Retail' THEN sales END) AS retail_sales,
  			SUM(CASE WHEN platform = 'Shopify' THEN sales END) AS shopify_sales,
  			SUM(sales) AS total_sales
    		FROM data_mart.clean_weekly_sales 
  		GROUP BY calender_year, TO_char(week_date, 'MONTH') 
		)
	SELECT year, month,
		retail_sales*100/total_sales AS retail_percent,
		shopify_sales*100/total_sales AS shopify_percent
	FROM transaction;


**7. What is the percentage of sales by demographic for each year in the dataset?**


	WITH demographic_sales AS (
    		SELECT calender_year AS year, 
 			demographic,
  			SUM(sales) AS total_demo_sales
    		FROM data_mart.clean_weekly_sales 
  		GROUP BY calender_year, demographic
		),
	total_yearly_sales AS(
  		SELECT calender_year AS year, 
  			SUM(sales) AS total_sales
    		FROM data_mart.clean_weekly_sales 
		GROUP BY calender_year)
  
	SELECT d.year, d.demographic,
		d.total_demo_sales*100/t.total_sales AS sales_percent
	FROM demographic_sales d
	JOIN total_yearly_sales t
	ON d.year=t.year
	ORDER BY d.year;

 ![image](https://github.com/user-attachments/assets/90fed1d8-7bae-45d9-86eb-5a2ff98e74fa)


 **8. Which age_band and demographic values contribute the most to Retail sales?**

 	WITH demo_age_sales AS (
   		 SELECT
 			age_band, demographic,
  			SUM(sales) AS total_demo_sales
    		FROM data_mart.clean_weekly_sales 
  		WHERE platform = 'Retail'
  		GROUP BY age_band, demographic
  		order by SUM(sales) 
		)
  
	SELECT * FROM demo_age_sales LIMIT 1

 ![image](https://github.com/user-attachments/assets/711e5de7-863b-450d-8f20-8e8b56594933)


 **9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

	 WITH avg_sales AS (
    			SELECT calender_year AS year, 
 				SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) /
  	SUM(CASE WHEN platform = 'Retail' THEN transactions ELSE 0 END ) AS Retail,
  	SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) /
  	SUM(CASE WHEN platform = 'Shopify' THEN transactions ELSE 0 END ) AS Shopify
    			FROM data_mart.clean_weekly_sales 
  			GROUP BY calender_year
 			ORDER BY calender_year
			)
  
		SELECT year,retail, shopify
		FROM avg_sales ;


 ![image](https://github.com/user-attachments/assets/fee1e5aa-8a7f-4e10-9ad7-bbd7712441f1)


 
