<h1 align="center">DATA MART</h1>

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


<h4 align=left>1. What day of the week is used for each week_date value?</h4>


	select TO_CHAR(week_date, 'Day') AS week_day from data_mart.clean_weekly_sales;

 ![image](https://github.com/user-attachments/assets/8fa786d3-52b7-4958-92ab-bc33cbdc63b6)


<h4 align=left>2. What range of week numbers are missing from the dataset?</h4>

	WITH week_sequence AS (
    		SELECT generate_series(MIN(week_number), MAX(week_number)) AS week_number
    		FROM data_mart.clean_weekly_sales
		)
	SELECT ws.week_number
		FROM week_sequence ws
	LEFT JOIN data_mart.clean_weekly_sales w ON ws.week_number = w.week_number
	WHERE w.week_number IS NULL
	ORDER BY ws.week_number;

 ![image](https://github.com/user-attachments/assets/39356715-9b40-4604-976e-013181ce4858)

 .
 ..continued.



<h4 align=left>3. How many total transactions were there for each year in the dataset?</h4>


 	WITH trans_count AS (
    		SELECT calender_year AS year,
  			COUNT(transactions) AS transaction_count
    			FROM data_mart.clean_weekly_sales 
  			GROUP BY calender_year
  			ORDER BY calender_year
		)
	SELECT * FROM trans_count;
 
![image](https://github.com/user-attachments/assets/e6d24c00-c20a-43eb-b302-d001d4ce3f75)


<h4 align=left>4. What is the total sales for each region for each month?</h4>

	WITH total_sales AS (
    		SELECT TO_CHAR(week_date, 'Month') AS month,
  			region AS region,
  			SUM(sales) AS total_sales
    		FROM data_mart.clean_weekly_sales 
  		GROUP BY TO_CHAR(week_date, 'Month'), region
  		ORDER BY TO_CHAR(week_date, 'Month')
		)
	SELECT * FROM total_sales;

 ![image](https://github.com/user-attachments/assets/65a43321-9654-4da5-9b3a-2d3e0919b223)
 


 <h4 align=left>5. What is the total count of transactions for each platform?</h4>

 	WITH transaction AS (
    	SELECT 
	  	platform AS platform,
	  	count(sales) AS count_of_transaction
    	FROM data_mart.clean_weekly_sales 
  	GROUP BY platform
	)
	SELECT * FROM transaction;

 ![image](https://github.com/user-attachments/assets/8bde809e-9cd6-402f-9e41-6681c1f11870)



 <h4 align=left>6.What is the percentage of sales for Retail vs Shopify for each month?</h4>

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

 ![image](https://github.com/user-attachments/assets/b2f23b67-5f11-4763-a421-dfde4858589b)



<h4 align=left>7. What is the percentage of sales by demographic for each year in the dataset?</h4>


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


 <h4 align=left>8. Which age_band and demographic values contribute the most to Retail sales?</h4>

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


 <h4 align =left >9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?</h4>

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

 

 <h2 align=center>3. Before & After Analysis</h2>
 <p>

 This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:</p>

<h4 align=left>1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?</h4>	

		
	WITH packaging_sales AS (
  		SELECT 
    			week_date, 
    			week_number, 
    			SUM(sales) AS total_sales
  		FROM data_mart.clean_weekly_sales
  		WHERE (week_number BETWEEN 21 AND 28) 
    			AND (calender_year = 2020)
  		GROUP BY week_date, week_number
		)
	, before_after_changes AS (
  		SELECT 
    			SUM(CASE 
      			WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_packaging_sales,
    			SUM(CASE 
      			WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_packaging_sales
  		FROM packaging_sales
		)

		SELECT 
  			after_packaging_sales - before_packaging_sales AS sales_variance, 
  			ROUND(100 * 
    				(after_packaging_sales - before_packaging_sales) 
    				/ before_packaging_sales,2) AS variance_percentage
		FROM before_after_changes;

![image](https://github.com/user-attachments/assets/57b0c6eb-2d05-4826-bb2f-5554a46a6a31)

 


  <h4 align=left> 2. What about the entire 12 weeks before and after?</h4>

  		
    	WITH packaging_sales AS (
  		SELECT 
    			week_date, 
    			week_number, 
    			SUM(sales) AS total_sales
  		FROM data_mart.clean_weekly_sales
  		WHERE (week_number BETWEEN 13 AND 37) 
    			AND (calender_year = 2020)
  		GROUP BY week_date, week_number
		)
	, before_after_changes AS (
  		SELECT 
    			SUM(CASE 
      				WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_packaging_sales,
    			SUM(CASE 
      				WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_packaging_sales
  		FROM packaging_sales
		)

		SELECT 
  			after_packaging_sales - before_packaging_sales AS sales_variance, 
  				ROUND(100 * 
    					(after_packaging_sales - before_packaging_sales) 
    					/ before_packaging_sales,2) AS variance_percentage
		FROM before_after_changes;

  

![image](https://github.com/user-attachments/assets/f4ed8a7d-bc34-4965-9f21-8676c951fabe)






   



 
