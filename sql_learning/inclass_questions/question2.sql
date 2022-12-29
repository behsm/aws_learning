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
WHERE stat_cd is not NULL
GROUP BY tran_date, stat_cd,lkp.population_cnt
ORDER BY tran_date, stat_cd





--2. To reach each remaining potential_customer_cnt cost 5$, then show me the states where company has to spend 2nd high $ amount.
--(make sure do potential_customer_cnt -allready customer count to get remaining potential customer count)
--on each day what is the 2nd highest amount you have to spend by state & day

WITH inq1 as (
SELECT tf.tran_date, tf.stat_cd,(lkp.potential_customer_cnt-count(distinct cust_id))*5 as promotion_cost, DENSE_RANK() OVER (PARTITION BY tran_date ORDER BY promotion_cost DESC ) AS rnk
FROM cards_ingest.tran_fact tf INNER JOIN lkp_data.lkp_state_details lkp ON tf.stat_cd = lkp.state_cd 
WHERE stat_cd is not NULL  --could do rank <=2 if you want the 1st record when there is only 1
GROUP BY tran_date, stat_cd, potential_customer_cnt
ORDER BY tran_date, promotion_cost DESC

)
SELECT * 
FROM inq1
WHERE rnk = 2 
/*
output:
"tran_date","stat_cd","promotion_cost","rnk"
"2022-01-01","TX","1495","1"
"2022-01-01","CA","990","2"
"2022-01-03","NY","495","1"
"2022-01-04","CA","990","1"
"2022-01-05","TX","1490","1"
"2022-02-01","NY","495","1"
"2022-02-03","TX","1495","1"
"2022-02-03","NY","495","2"
"2022-02-05","TX","1495","1"
"2022-02-05","CA","995","2"
"2022-03-01","CA","995","1"
"2022-03-02","CA","995","1"
"2022-04-01","CA","995","1"
"2022-07-03","NV","445","1"
*/





/*
3. Same as question 1. But 
the number of customer from transaction table is total number of unique customer till that date.
(Hint use window function)

4. Same as question 2. 
If state cd is NULL  and     COALESCE/CASE 
cust_id is cust_109 
then  TX  
else CA and calculate states where
company has to spend 2nd lowest $ amount from .

5. Show me the total number of customer company has 
, total population,
 and potential_customer_cnt across all the states
 */
