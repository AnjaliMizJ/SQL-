**DATA MART**

***Case Study Questions**
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

***2. What range of week numbers are missing from the dataset?**

	WITH week_sequence AS (
    		SELECT generate_series(MIN(week_number), MAX(week_number)) AS week_number
    		FROM data_mart.clean_weekly_sales
		)
	SELECT ws.week_number
		FROM week_sequence ws
	LEFT JOIN data_mart.clean_weekly_sales w ON ws.week_number = w.week_number
	WHERE w.week_number IS NULL
	ORDER BY ws.week_number;


***3. How many total transactions were there for each year in the dataset?**


 	WITH trans_count AS (
    		SELECT calender_year AS year,
  			COUNT(transactions) AS transaction_count
    			FROM data_mart.clean_weekly_sales 
  			GROUP BY calender_year
  			ORDER BY calender_year
		)
	SELECT * FROM trans_count;

***4. What is the total sales for each region for each month?**

	WITH total_sales AS (
    		SELECT TO_CHAR(week_date, 'Month') AS month,
  			region AS region,
  			SUM(sales) AS total_sales
    		FROM data_mart.clean_weekly_sales 
  		GROUP BY TO_CHAR(week_date, 'Month'), region
  		ORDER BY TO_CHAR(week_date, 'Month')
		)
	SELECT * FROM total_sales;
