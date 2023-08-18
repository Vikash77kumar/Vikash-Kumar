/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  both first name and last name are in upper case, customer email id,  customer creation year and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Hint: Use CASE statement, no permanent change in the table is required. 
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
*/

## Answer 1
SELECT customer_id,
       CONCAT(CASE WHEN CUSTOMER_GENDER= 'M' THEN 'Mr. ' ELSE 'Ms. ' END, UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME)) AS customer_name,
       CUSTOMER_EMAIL,
       YEAR(customer_creation_date) AS customer_creation_year,
       CASE 
           WHEN YEAR(customer_creation_date) < 2005 THEN 'A'
           WHEN YEAR(customer_creation_date) >= 2005 AND YEAR(customer_creation_date) < 2011 THEN 'B'
           ELSE 'C'
       END AS category
FROM online_customer;

/* Q2. Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, inventory values ( product_quantity_avail * product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Hint: Use CASE statement, no permanent change in table required. 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */

## Answer 2
SELECT p.product_id,
       p.product_desc,
       p.product_quantity_avail,
       p.product_price,
       p.product_quantity_avail * p.product_price AS inventory_value,
       CASE 
           WHEN p.product_price > 200000 THEN p.product_price * 0.8
           WHEN p.product_price > 100000 THEN p.product_price * 0.85
           ELSE p.product_price * 0.9
       END AS new_price
FROM product p
LEFT JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL
ORDER BY inventory_value DESC;

/* Q3. Write a query to display Product_class_code, Product_class_description, 
Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price).
Information should be displayed for only those product_class_code which
 have more than 1,00,000 Inventory Value. Sort the output with respect to
 decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS] */

## Answer 3

SELECT pc.product_class_code,
       pc.product_class_desc,
       COUNT(DISTINCT p.product_desc) AS product_desc_count,
       SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM product p
INNER JOIN product_class pc
ON p.product_class_code = pc.product_class_code
GROUP BY pc.product_class_code
HAVING inventory_value > 100000
ORDER BY inventory_value DESC;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
 [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER] */
 
## Answer 4
SELECT oc.customer_id, CONCAT(CASE WHEN CUSTOMER_GENDER= 'M' THEN 'Mr. ' ELSE 'Ms. ' END, (CUSTOMER_FNAME), ' ', (CUSTOMER_LNAME)) AS full_name ,
 oc.customer_email, oc.customer_phone, a.country
FROM ONLINE_CUSTOMER oc
JOIN ADDRESS a ON oc.address_id = a.address_id
WHERE EXISTS (
	SELECT 1 FROM order_header oh WHERE oh.customer_id = oc.customer_id AND oh.order_status ='Cancelled'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) = (SELECT COUNT(*) FROM order_header WHERE customer_id = oc.customer_id));

    
/* Q5. Write a query to display Shipper name, City to which it is catering,
 num of customer catered by the shipper in the city , number of consignment
 delivered to that city for Shipper DHL 
Hint: The answer should only be based on Shipper_Name -- DHL.
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */

## Answer 5. 
SELECT s.shipper_name, a.city, COUNT(DISTINCT oc.customer_id) AS num_of_customers,
COUNT(DISTINCT oh.order_id) AS num_of_consignments
FROM SHIPPER s
JOIN ORDER_HEADER oh ON s.shipper_id = oh.shipper_id
JOIN ONLINE_CUSTOMER oc ON oh.customer_id = oc.customer_id
JOIN ADDRESS a ON oc.address_id = a.address_id
WHERE s.shipper_name = 'DHL'
GROUP BY s.shipper_name, a.city;


/* Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, 
need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
  [NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] */

## Answer 6. (Done but giving 47 row instead of 60,
SELECT oi.product_id, p.product_desc, p.product_quantity_avail,
       SUM(product_quantity) AS quantity_sold,
       CASE WHEN pc.product_class_desc IN ('Electronics''Computer') THEN
            CASE 
		WHEN SUM(product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
        WHEN product_quantity_avail < (SUM(product_quantity) * 0.1) THEN 'Low inventory, need to add inventory'
		WHEN product_quantity_avail < (SUM(product_quantity) * 0.5) THEN 'Medium inventory, need to add some inventory'
        ELSE 'Sufficient inventory'
        END  
    WHEN ('Mobiles' 'Watches') THEN
        CASE 
        WHEN SUM(product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
        WHEN  product_quantity_avail < (SUM(product_quantity) * 0.2) THEN 'Low inventory, need to add inventory'
        WHEN  product_quantity_avail < (SUM(product_quantity) * 0.6) THEN 'Medium inventory, need to add some inventory'
        ELSE 'Sufficient inventory'
        END    
    ELSE
        CASE 
        WHEN SUM(product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
        WHEN  product_quantity_avail < (SUM(product_quantity) * 0.3) THEN 'Low inventory, need to add inventory'
        WHEN  product_quantity_avail < (SUM(product_quantity) * 0.7) THEN 'Medium inventory, need to add some inventory'
        ELSE 'Sufficient inventory'
            END
       END AS inventory_status
FROM product p
JOIN product_class pc ON p.PRODUCT_CLASS_code = pc.PRODUCT_CLASS_code
JOIN  order_items oi ON p.product_id = oi.product_id
GROUP BY product_id,product_desc;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

## Answer 7.
SELECT oi.order_id, SUM((len *width * height) * product_quantity) AS order_volume
FROM ORDER_ITEMS oi
JOIN PRODUCT p ON oi.product_id = p.product_id
WHERE oi.order_id IN (
  SELECT order_id FROM ORDER_ITEMS GROUP BY order_id HAVING SUM((len *width * height) * product_quantity)
  <= ( SELECT (len *width * height) FROM CARTON WHERE carton_id = 10))
GROUP BY oi.order_id
ORDER BY order_volume DESC
LIMIT 1;

  
  /* Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

## Answer 8.
SELECT oc.customer_id, CONCAT(CASE WHEN CUSTOMER_GENDER= 'M' THEN 'Mr. ' ELSE 'Ms. ' END, (CUSTOMER_FNAME), ' ', (CUSTOMER_LNAME)) AS full_name ,
SUM(product_quantity) AS total_quantity, SUM(product_quantity * p.product_price) AS total_value
FROM ONLINE_CUSTOMER oc 
JOIN ORDER_HEADER oh ON oc.customer_id = oh.customer_id 
JOIN ORDER_ITEMS oi ON oh.order_id = oi.order_id 
JOIN PRODUCT p ON oi.product_id = p.product_id 
WHERE oh.payment_mode = 'Cash' AND CUSTOMER_LNAME LIKE 'G%'
GROUP BY oc.customer_id, full_name;

/* Q9. Write a query to display product_id, product_desc and total quantity of products
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty. 
Expected 6 rows in final output

Hint:  (USE SUB-QUERY)
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]*/

## Answer 9.
SELECT p.product_id, p.product_desc, SUM(oi.product_quantity) AS total_quantity
FROM order_items oi
JOIN product p ON p.product_id = oi.product_id
JOIN order_header oh ON oi.order_id = oh.order_id
JOIN online_customer oc ON oc.customer_id = oh.customer_id
JOIN address a ON oc.address_id = a.address_id
WHERE oi.product_id <> 201
AND oi.order_id IN (
  SELECT oi2.order_id
  FROM order_items oi2
  JOIN order_header oh2 ON oi2.order_id = oh2.order_id
  JOIN online_customer oc2 ON oh2.customer_id = oc2.customer_id
  JOIN address a2 ON oc2.address_id = a2.address_id
  WHERE oi2.product_id  like 201
  AND a2.city NOT IN ('Bangalore', 'New Delhi'))
GROUP BY p.product_id, p.product_desc
ORDER BY total_quantity DESC
LIMIT 6;


/* Q10. Write a query to display the order_id, customer_id and customer fullname,
 total quantity of products shipped for order ids which are even and shipped to
 address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS] */

## Answer 10.
SELECT OH.order_id, OH.customer_id,CONCAT(CASE WHEN CUSTOMER_GENDER= 'M' THEN 'Mr. ' ELSE 'Ms. ' END, (CUSTOMER_FNAME), ' ', (CUSTOMER_LNAME)) AS full_name, SUM(product_quantity) AS total_quantity_shipped
FROM ORDER_HEADER OH
JOIN ONLINE_CUSTOMER OC ON OC.customer_id = OH.customer_id
JOIN ADDRESS A ON a.address_id = oc.address_id
JOIN ORDER_ITEMS OI ON OI.order_id = OH.order_id
WHERE MOD(oh.order_id, 2) = 0
AND LEFT(A.pincode, 1) != '5'
GROUP BY customer_id,order_id, full_name HAVING COUNT(Oc.customer_id) ;

	

 



SELECT oh.order_id, oc.customer_id, CONCAT(CASE WHEN CUSTOMER_GENDER= 'M' THEN 'Mr. ' ELSE 'Ms. ' END, (CUSTOMER_FNAME), ' ', (CUSTOMER_LNAME)) AS full_name, SUM(product_quantity) AS total_quantity_shipped
FROM online_customer oc
JOIN order_header oh ON oc.customer_id = oh.customer_id
JOIN order_items oi ON oh.order_id = oi.order_id
JOIN address a ON a.address_id = oc.address_id
WHERE MOD(oh.order_id, 2) = 0
AND a.pincode NOT LIKE '5%'
GROUP BY oc.customer_id,oh.order_id, full_name;



SELECT oh.order_id, oh.customer_id,pincode, CONCAT(CASE WHEN CUSTOMER_GENDER= 'M' THEN 'Mr. ' ELSE 'Ms. ' END, (CUSTOMER_FNAME), ' ', (CUSTOMER_LNAME)) AS full_name, 
SUM(product_quantity) AS total_quantity_shipped
FROM online_customer oc
JOIN order_header oh  on oh.customer_id = oc.customer_id
JOIN ORDER_ITEMS oi ON oi.order_id = oh.order_id
JOIN ADDRESS a ON a.address_id = oc.address_id
WHERE MOD(oh.order_id, 2) = 0 AND a.pincode NOT LIKE '5%'
GROUP BY oh.order_id, oh.customer_id,full_name;

/*Q9. Write a query to display product_id, product_desc and total quantity of products
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty. 
Expected 6 rows in final output
Hint:  (USE SUB-QUERY)
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]*/

## Answer 9.(Done but ngetting 18 rows instead of 6, recheck)
SELECT p.product_id, p.product_desc, SUM(product_quantity) AS tot_qty
FROM order_items oi
INNER JOIN order_header oh ON oh.order_id = oi.order_id
INNER JOIN address a ON address_id = a.address_id
INNER JOIN product p ON oi.product_id = p.product_id
INNER JOIN ONLINE_CUSTOMER oc ON oh.customer_id = oc.customer_id
WHERE oi.order_id IN (
    SELECT oi.order_id 
    FROM order_items oi
    WHERE oi.product_id= 201)
AND a.city  NOT IN ('Bangalore' 'New Delhi')
GROUP BY p.product_id, p.product_desc
ORDER BY tot_qty DESC
LIMIT 6 ;





SELECT p.product_id, p.product_desc, SUM(oi.product_quantity) AS total_quantity
FROM order_items oi
JOIN product p ON oi.product_id = p.product_id
JOIN order_header oh ON oi.order_id = oh.order_id
JOIN online_customer oc ON oh.customer_id = oc.customer_id
JOIN address a ON oc.address_id = a.address_id
WHERE oi.product_id <> 201
AND oi.order_id IN (
  SELECT oi2.order_id
  FROM order_items oi2
  JOIN order_header oh2 ON oi2.order_id = oh2.order_id
  JOIN online_customer oc2 ON oh2.customer_id = oc2.customer_id
  JOIN address a2 ON oc2.address_id = a2.address_id
  WHERE oi2.product_id = 201
  AND a2.city NOT IN ('Bangalore', 'New Delhi'))
GROUP BY p.product_id, p.product_desc
ORDER BY total_quantity DESC
Limit 6;



select * from product_class; 
select * from product; 
select * from order_items; 