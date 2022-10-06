# Model-Vehicle-Sales-Analysis-Using-SQL-And-Python

CREATE VIEW customer_profit_report AS
SELECT shipped_orders.customerNumber AS customer_id,
       ROUND(SUM(shipped_order_details.quantityOrdered * (shipped_order_details.priceEach - products.buyPrice)),2) AS profit,
       COUNT(*) AS no_of_orders
  FROM shipped_orders
  JOIN shipped_order_details
    ON shipped_order_details.orderNumber=shipped_orders.orderNumber
  JOIN products
    ON shipped_order_details.productCode=products.productCode
 GROUP BY shipped_orders.customerNumber;

SELECT customers.contactLastName||", "||customers.contactFirstName AS Name,
       customers.city AS City,
       customers.country AS Country,
       customer_profit_report.profit AS Profit_Earned
  FROM customers
  JOIN customer_profit_report
    ON customers.customerNumber = customer_profit_report.customer_id
 WHERE customer_profit_report.customer_id IN (SELECT customer_id
                                                FROM customer_profit_report
                                               ORDER BY profit DESC
                                               LIMIT 5)
 ORDER BY customer_profit_report.profit DESC;
