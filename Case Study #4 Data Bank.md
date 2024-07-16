![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/983e0718-7cf3-4c95-8020-0539dca6d0a0)


**Introduction**

There is a new innovation in the financial industry called Neo-Banks: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!


***A. Customer Nodes Exploration***
**How many unique nodes are there on the Data Bank system?**

**solution**

              SELECT COUNT(DISTINCT node_id) AS node_count FROM data_bank.customer_nodes  



      ![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/4e817779-1ee5-42e1-b455-edac88083004)
      

      -There are 5 disctinct nodes.


**What is the number of nodes per region?**

**solution**

        	SELECT customer.region_id , regions.region_name, COUNT(customer.node_id) AS "Number of Nodes"
          FROM data_bank.customer_nodes customer
              JOIN data_bank.regions regions ON regions.region_id = customer.region_id 
          GROUP BY customer.region_id, regions.region_name
          ORDER BY "Number of Nodes"


![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/a36eeb8b-556e-4201-b969-dce10d649858)


**How many customers are allocated to each region?**

**solution**


	    SELECT regions.reGion_name AS region, COUNT(DISTINCT customer.customer_id) AS "Number of Customers"
      FROM data_bank.customer_nodes customer
          JOIN data_bank.regions regions ON regions.region_id = customer.region_id 
      GROUP BY regions.region_name

      ![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/765f2f5f-11b4-4ac6-9b3a-1d6bae9c07b4)


      - Australia is with highest number of cutomers followed by america whereas Europe with the least number of customers.



**How many days on average are customers reallocated to a different node?**

**solution**
          
          SELECT ROUND(AVG(end_date - start_date),2) AS avg_reallocation
          FROM data_bank.customer_nodes
          WHERE END_DATE!='9999-12-31'

![image](https://github.com/AnjaliMizJ/SQL-/assets/31090029/5382def8-8c26-4481-9a83-530fc7dc08a7)

**What is the unique count and total amount for each transaction type?**

	SELECT txn_type, COUNT(DISTINCT txn_date), SUM(txn_amount)
		FROM data_bank.customer_transactions
	GROUP BY txn_type


**What is the average total historical deposit counts and amounts for all customers?***

	SELECT customer_id, (COUNT(txn_type)), ROUND(AVG(txn_amount),2)
		FROM data_bank.customer_transactions
	WHERE txn_type = 'deposit'
	GROUP BY customer_id*/


**For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

	WITH CUSTCTE as (
		SELECT EXTRACT(MONTH FROM txn_date) AS month_, customer_id, 
			SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit,
    			SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase,
    			SUM(CASE WHEN txn_type = 'withdrawl' THEN 1 ELSE 0 END) AS withdrawl
		FROM data_bank.customer_transactions
		GROUP BY EXTRACT(MONTH FROM txn_date), customer_id
		ORDER BY EXTRACT(MONTH FROM txn_date)
  		)

		SELECT month_, count(customer_id)
			FROM CUSTCTE
		WHERE deposit > 1 and (purchase = 1 or withdrawl = 1 )
		GROUP BY month_
    


**What is the closing balance for each customer at the end of the month?**

		WITH CloingblnceCTE as
			(Select customer_id, EXTRACT(MONTH FROM txn_date) AS MONTH,  
				SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) OVER(PARTITION BY customer_id ORDER BY txn_date ) AS 					ClosingBalance
			FROM data_bank.customer_transactions
 			) 

			SELECT customer_id, MONTH, SUM(ClosingBalance)
				FROM CloingblnceCTE
			GROUP BY customer_id, MONTH
			ORDER BY customer_id, MONTH


**What is the percentage of customers who increase their closing balance by more than 5%?**

	WITH CloingblnceCTE as
			(Select customer_id, EXTRACT(MONTH FROM txn_date) AS MONTH,  
				SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) OVER(PARTITION BY customer_id ORDER BY txn_date ) AS 					ClosingBalance
			FROM data_bank.customer_transactions),


		CLOSINGBLNC AS
			(SELECT customer_id, MONTH, SUM(ClosingBalance) as closingamnt,
 			LAG(SUM(ClosingBalance)) OVER(PARTITION BY customer_id ORDER BY month) AS prevbal
			FROM CloingblnceCTE
			GROUP BY customer_id, MONTH
			ORDER BY customer_id, MONTH)


 
 			SELECT (COUNT(customer_id)*100/
              				(SELECT COUNT(DISTINCT customer_id) FROM data_bank.customer_transactions)) AS PER
	 		FROM CLOSINGBLNC
 			WHERE ((closingamnt-prevbal)/prevbal)*100 > 5
 





