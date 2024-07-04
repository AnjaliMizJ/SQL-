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





