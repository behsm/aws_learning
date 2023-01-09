--1. Create a schema lkp_data.
--2. Create a table lkp_state_details. col (state_cd,population_cnt, potential_customer_cnt)
--data:
--NY,200,100
--CA,500,200
--TX,400,300
--NV,100,90
--NJ,200,70



--Question:
--1. Join  cards_ingest.tran_fact with lkp_state_details on state cd. Make sure if any Null Values from fact remove those records
--Show me tran_date,state, number of customer per tran_date and state and number of customer company can target for promotion
--who are not customer in but still lives in the state (population - number of customer)
--notes from class:
--join, get unique customers per date, subtract from population count


SELECT tran_date, stat_cd, count(distinct cust_id) as num_customers, population_cnt-num_customers as promotion_target_cnt
FROM cards_ingest.tran_fact tf INNER JOIN lkp_data.lkp_state_details lkp ON tf.stat_cd = lkp.state_cd
GROUP BY tran_date, stat_cd,lkp.population_cnt
ORDER BY tran_date, stat_cd




--2. To reach each remaining potential_customer_cnt cost 5$, then show me the states where company has to spend 2nd high $ amount.
--(make sure do potential_customer_cnt -allready customer count to get remaining potential customer count)
--on each day what is the 2nd highest amount you have to spend by state & day


WITH inq1 as (
SELECT tf.tran_date, tf.stat_cd,(lkp.potential_customer_cnt-count(distinct cust_id))*5 as promotion_cost, DENSE_RANK() OVER (PARTITION BY tran_date ORDER BY promotion_cost DESC ) AS rnk
FROM cards_ingest.tran_fact tf INNER JOIN lkp_data.lkp_state_details lkp ON tf.stat_cd = lkp.state_cd 
GROUP BY tran_date, stat_cd, potential_customer_cnt
ORDER BY tran_date, promotion_cost DESC
)
SELECT * 
FROM inq1
WHERE rnk = 2

--3. Same as question 1. But 
--the number of customer from transaction table is total number of unique customer till that date.
--(Hint use window function)


SELECT tran_date, stat_cd, cust_id,
SUM(CASE WHEN visits_in_state = 1 THEN '1' ELSE '0'END) OVER (PARTITION BY stat_cd ORDER BY tran_date,stat_cd ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as unique_customers,
population_cnt-unique_customers as promotion_target_cnt FROM 
(
SELECT tran_date, stat_cd, cust_id, population_cnt,
count(cust_id) OVER (PARTITION BY stat_cd,cust_id ORDER BY tran_date,stat_cd ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as visits_in_state 
FROM cards_ingest.tran_fact tf INNER JOIN lkp_data.lkp_state_details lkp ON tf.stat_cd = lkp.state_cd
GROUP BY tran_date, stat_cd,population_cnt, cust_id
ORDER BY tran_date, stat_cd
)
ORDER BY tran_date,stat_cd

/*
4. Same as question 2. 
If state cd is NULL  and     
cust_id is cust_109    
then  TX      
else CA and calculate states where
company has to spend 2nd lowest $ amount from .
*/

WITH inq1 as (
    SELECT tran_date, 
    COALESCE(stat_cd, CASE WHEN cust_id = 'cust_109' THEN 'TX' ELSE 'CA' END) as stat_cd,
    cust_id
    FROM cards_ingest.tran_fact
), inq2 as (
SELECT inq1.tran_date, inq1.stat_cd,(lkp.potential_customer_cnt-count(distinct cust_id))*5 as promotion_cost, DENSE_RANK() OVER (PARTITION BY tran_date ORDER BY promotion_cost DESC ) AS rnk
FROM inq1 INNER JOIN lkp_data.lkp_state_details lkp ON inq1.stat_cd = lkp.state_cd 
GROUP BY tran_date, stat_cd, potential_customer_cnt
ORDER BY tran_date, promotion_cost DESC
)
SELECT * 
FROM inq2
WHERE rnk = 2

/*
5. Show me the total number of customer company has 
, total population,
 and potential_customer_cnt across all the states

 distinct cust_id/pop from data table/potential customer = potential-count
 */

WITH inq1 as (
    SELECT tran_date,
    COALESCE(stat_cd, CASE WHEN cust_id = 'cust_109' THEN 'TX' ELSE 'CA' END) as stat_cd,
    cust_id
    FROM cards_ingest.tran_fact
)
SELECT inq1.tran_date, inq1.stat_cd,(lkp.potential_customer_cnt-count(distinct cust_id))*5 as promotion_cost 
FROM inq1 INNER JOIN lkp_data.lkp_state_details lkp ON inq1.stat_cd = lkp.state_cd 
GROUP BY tran_date, stat_cd, potential_customer_cnt
ORDER BY tran_date, promotion_cost DESC
)
SELECT * 
FROM inq2



WITH inq1 as (
    SELECT tran_date, tf.cust_id,
    COALESCE(stat_cd, CASE WHEN cust_id = 'cust_109' THEN 'TX' ELSE 'CA' END) as stat_cd
    FROM cards_ingest.tran_fact tf
), inq2 as (
SELECT inq1.stat_cd,(lkp.potential_customer_cnt-count(distinct inq1.cust_id))*5 as promotion_cost, 
DENSE_RANK() OVER (PARTITION BY tran_date ORDER BY promotion_cost DESC ) AS rnk
FROM inq1 INNER JOIN lkp_data.lkp_state_details lkp ON inq1.stat_cd = lkp.state_cd 
GROUP BY tran_date, stat_cd, potential_customer_cnt
ORDER BY tran_date, promotion_cost DESC
)
SELECT *
FROM inq2
WHERE rnk = 1




