/* 
         ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         + Guided Project: Customers and Products Analysis Using SQL +
         ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 Introduction:

 As part of this project we will be analysing the scale care model datbase using SQL to answer following questions

 Question 1: Which products should we order more of or less of?
 Question 2: How should we tailor marketing and communication strategies to customer behaviors?
 Question 3: How much can we spend on acquiring new customers?

 Database Summary:

 The database contains 8 tables as follows.
   
 1) Customers:    Contains customer data; 'customerNumber' is the 'primary key'; 'salesRepEmployeeNumber' is the 'foreign key';
       		      Relationship with 'orders' and 'payments' tables on 'customerNumber'; 
				  Relationship with 'employees' table on 'salesRepEmployeeNumber'
					
 2) Employees:    Contains all employee information; 'employeeNumber' is the 'primary key'; 'officeCode' is the 'foreign key';
				  Relationship with 'offices' table on 'officeCode'; Relationship with 'customers' table on 'employeeNumber';
				  Self-relationship between 'employeeNumber' and 'reportsTo'
   
 3) Offices:      Contains sales office information; 'officeCode' is the 'primary key'; 
				  Relationship with 'employees' table on 'officeCode'
   
 4) Orders:       Contains customers' sales orders; 'orderNumber' is the 'primary key'; 'customerNumber' is the 'foreign key';
				  Relationship with 'customers' table on 'customerNumber'; 
				  Relationship with 'orderdetails' table on 'orderNumber'
   
 5) OrderDetails: Contains sales order line for each sales order; 'orderNumber' and 'productCode' are 'primary key';
                  'orderNumber' is also foreign key; Relationship with 'orders' table on 'orderNumber';
				  Relationship with 'products' table on 'productCode'
   
 6) Payments:     Contains customers' payment records; 'customerNumber' and 'checkNumber' are 'primary key';
                  'customerNumber' is also foreign key; Relationship with 'customers' table on 'customerNumber'
   
 7) Products:     Contains a list of scale model cars; 'productCode' is the 'primary key'; 'productLine' is the 'foreign key';
  				  Relationship 'orderdetails' table on 'productCode'; Relationship with 'productlines' table on 'productLine'
   
 8) ProductLines: Contains a list of product line categories; 'productLine' is the 'primary key';
				  Relationship with 'products' table on 'productLine' 

 */				 

 -- SQL Queries to analyse the database as follows:

 -- Screen 3: Write a query to display all tables, no. of attributes per table and no.rows per table, primary, foreign key and relationships

 SELECT 'Customers' AS table_name,
        13 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM customers
  
  UNION ALL
 
 SELECT 'Products' AS table_name,
        9 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM products
  
  UNION ALL

 SELECT 'ProductLines' AS table_name,
        4 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM productlines
  
  UNION ALL 
   
 SELECT 'Orders' AS table_name,
        7 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM orders
  
  UNION ALL
 
 SELECT 'OrderDetails' AS table_name,
        5 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM orderdetails
  
  UNION ALL
 
 SELECT 'Payments' AS table_name,
        4 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM payments
  
  UNION ALL
 
 SELECT 'Employees' AS table_name,
        8 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM employees
  
  UNION ALL
 
 SELECT 'Offices' AS table_name,
        9 AS number_of_attributes,
	    COUNT(*) AS number_of_rows
   FROM offices;
  
  -- Screen 4: Write a query to compute the low stock for each product using a correlated subquery.
 
  SELECT productCode,
        ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
		                                      FROM products pr
											 WHERE od.productCode = pr.productCode), 2) AS low_stock
   FROM orderdetails od
  GROUP BY productCode
  ORDER BY low_stock
  LIMIT 10;
  
    -- Screen 4: Write a query to compute the product performance for each product.
	 
  SELECT productCode, 
         SUM(quantityOrdered * priceEach) AS prod_perf
    FROM orderdetails
   GROUP BY productCode
   ORDER BY prod_perf DESC
   LIMIT 10;
   
  -- Screen 4: Write a query to combine low stock and product performance queries using CTE to display priority products for restocking
   
  WITH
  prfrm AS (
    SELECT productCode,
           SUM(quantityOrdered) * 1.0 AS qntOrdr,	
           SUM(quantityOrdered * priceEach) AS prod_perf
      FROM orderdetails
     GROUP BY productCode
  ),
  lstk AS (
    SELECT pr.productCode, 
	       pr.productName, 
		   pr.productLine,
           ROUND(SUM(prfrm.qntOrdr * 1.0) / pr.quantityInstock, 2) AS low_stock
      FROM products pr
	  JOIN prfrm
	    ON pr.productCode = prfrm.productCode
     GROUP BY pr.productCode
	 ORDER BY low_stock
	 LIMIT 10
  )
    SELECT lstk.productName, 
	       lstk.productLine
	  FROM lstk
	  JOIN prfrm
	    ON lstk.productCode = prfrm.productCode
	 ORDER BY prfrm.prod_perf DESC;
	 
  -- Screen 5: Write a query to display customers and profit generated by them by joining products, orderdetails and orders tables
  
  SELECT os.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit_gen  
    FROM products pr
	JOIN orderdetails od
	  ON pr.productCode = od.productCode
	JOIN orders os
	  ON od.orderNumber = os.orderNumber
   GROUP BY os.customerNumber;
      
  -- Screen 6: Write a query to find top 5 customers in terms of profit generation by using CTE
  
  WITH
  profit_gen_table AS (
    SELECT os.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS prof_gen  
      FROM products pr
	  JOIN orderdetails od
	    ON pr.productCode = od.productCode
	  JOIN orders os
	    ON od.orderNumber = os.orderNumber
     GROUP BY os.customerNumber
  )
	SELECT contactLastName, contactFirstName, city, country, pg.prof_gen
	  FROM customers cust
	  JOIN profit_gen_table pg
	    ON pg.customerNumber = cust.customerNumber
	 ORDER BY pg.prof_gen DESC
	 LIMIT 5;
	 
  -- Screen 6: Write a query to find bottom 5 customers in terms of profit generation using CTE
	  
  WITH
  profit_gen_table AS (
	SELECT os.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS prof_gen  
      FROM products pr
	  JOIN orderdetails od
	    ON pr.productCode = od.productCode
	  JOIN orders os
	    ON od.orderNumber = os.orderNumber
     GROUP BY os.customerNumber
  )
	SELECT contactLastName, contactFirstName, city, country, pg.prof_gen
	  FROM customers cust
	  JOIN profit_gen_table pg
	    ON pg.customerNumber = cust.customerNumber
	 ORDER BY pg.prof_gen
	 LIMIT 5;
	 
  -- Screen 7: Write a query to compute the average of customer lifetime value (LTV) using CTE
  
  WITH
  profit_gen_table AS (
	SELECT os.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS prof_gen  
      FROM products pr
	  JOIN orderdetails od
	    ON pr.productCode = od.productCode
	  JOIN orders os
	    ON od.orderNumber = os.orderNumber
     GROUP BY os.customerNumber
  )
   SELECT AVG(pg.prof_gen) AS lyf_tym_val
     FROM profit_gen_table pg;
	 
  /* 
  
  Conclusion:
 
  Question 1: Which products should we order more of or less of?
  
    Answer 1: Analysing the query results of comparing low stock with product performance we can see that,
              6 out 10 cars belong to 'Classic Cars' product line. They sell frequently with high product performance.
		      As such we should be re-stocked these frequently
 
  Question 2: How should we tailor marketing and communication strategies to customer behaviors?
  
    Answer 2: Analysing the query results of top and bottom customers in terms of profit generation,
              we need to offer loyalty rewards and priority services for our top customers to retain them.
			  Also for bottom customers we need to solicit feedback to better understand their preferences, 
			  expected pricing, discount and offers to increase our sales
 
  Question 3: How much can we spend on acquiring new customers?
  
    Answer 3: The average customer liftime value of our store is $ 39,040. This means for every new customer we make profit of 39,040 dollars. 
	          We can use this to predict how much we can spend on new customer acquisition, 
			  at the same time maintain or increase our profit levels.
	          
  PROJECT END */