**Introduction**
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

**Problem Statement**
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

sales
menu
members
For complete dataset refer to the link: https://8weeksqlchallenge.com/case-study-1/

**1. What is the total amount each customer spent at the restaurant?** we will use aggregate sum function to get the total spent amount and groupby customer_id to get sum of amount for each customer and then join as price is another table of menu.
	
**solution:**      
		
  			SELECT sales.customer_id AS Customer, SUM(menu.price) AS Total_Spent
            		FROM dannys_diner.sales sales 
            		JOIN dannys_diner.menu menu ON sales.product_id = menu.product_id
          	   GROUP BY sales.customer_id

**2. How many days has each customer visited the restaurant?** we will use aggregate count function and wrapped with distinct to get unique day to avoud repetetion and group by customer_id to get count of days visited by each customer.

**solution**
		
  		SELECT customer_id AS CUSTOMER, COUNT(DISTINCT(order_date))
       		 FROM dannys_diner.sales
        	GROUP BY customer_id

**3. What was the first item from the menu purchased by each customer?**

**solution:**
		
  		WITH RANK_PRODUCT_CTE AS
       		 (SELECT customer_id, order_date, product_name, 
        		DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS 			rank
        	FROM dannys_diner.sales sales 
        	JOIN dannys_diner.menu menu ON sales.product_id=menu.product_id
       		)
        
        	SELECT customer_id, product_name
        	FROM RANK_PRODUCT_CTE
        	WHERE rank = 1
        	GROUP BY customer_id, product_name

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

**solution:**	

			SELECT menu.product_name, COUNT(sales.product_id) AS p_count
    			FROM dannys_diner.sales sales 
    			JOIN dannys_diner.menu menu ON sales.product_id=menu.product_id
    		GROUP BY sales.product_id,  menu.product_name
    		ORDER BY p_count DESC LIMIT 1


**5. Which item was the most popular for each customer?**
**solution***

		WITH  CTErank_fav_food AS
			(SELECT sales.customer_id AS customer, COUNT(sales.product_id) AS prod_id, menu.product_name AS prod_name, 
     			RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) 		DESC) AS 	rank1
    			FROM dannys_diner.sales sales
    			JOIN dannys_diner.menu menu ON sales.product_id=menu.product_id
    			GROUP BY sales.customer_id,  menu.product_name)
    
    	
    		SELECT customer, prod_id, prod_name, rank1
    		FROM CTErank_fav_food
    		WHERE rank1=1

**6. Which item was purchased first by the customer after they became a member?**

**solution**

		WITH firstCTEproduct AS
    		(SELECT sales.customer_id, sales.order_date, sales.product_id, members.join_date, DENSE_RANK() OVER(PARTITION BY sales.product_id ORDER BY 				sales.order_date) AS rank1
     			FROM dannys_diner.sales sales
     				JOIN dannys_diner.members members
     				ON sales.customer_id = members.customer_id
	     		WHERE sales.order_date >= members.join_date
     			)
     
     		SELECT s.customer_id, s.order_date, s.product_id
     			FROM firstCTEproduct s
     				JOIN dannys_diner.menu menu
     				ON s.product_id = menu.product_id
     			WHERE rank1 = 1
     

**7. Which item was purchased just before the customer became a member?**

**solution:**

		
  		WITH beforeCTEproduct AS
    		(SELECT sales.customer_id, sales.order_date, sales.product_id, members.join_date, DENSE_RANK() OVER(PARTITION BY sales.product_id ORDER BY 				sales.order_date) AS rank1
     		FROM dannys_diner.sales sales
     			JOIN dannys_diner.members members
     			ON sales.customer_id = members.customer_id
     		WHERE sales.order_date < members.join_date
     		)
     
     		SELECT s.customer_id, s.order_date, menu.product_name
     		FROM beforeCTEproduct s
     			JOIN dannys_diner.menu menu
     			ON s.product_id = menu.product_id
     		WHERE rank1 = 1
     		ORDER BY s.customer_id

**8. What is the total items and amount spent for each member before they became a member?**

**solution**

		SELECT sales.customer_id, COUNT( DISTINCT sales.product_id), SUM(menu.price)
    		FROM dannys_diner.sales sales
     			JOIN dannys_diner.menu menu
     			ON sales.product_id = menu.product_id
     				JOIN dannys_diner.members members
     				ON sales.customer_id = members.customer_id
     		WHERE sales.order_date < members.join_date
     		GROUP BY sales.customer_id
