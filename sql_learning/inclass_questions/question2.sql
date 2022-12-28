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

SELECT cust_id, stat_cd FROM cards_ingest.tran_fact
WHERE stat_cd is not null
GROUP BY cust_id, stat_cd
/*OUTPUT:
"cust_id","stat_cd"
"cust_101","NY"
"cust_102","CA"
"cust_103","CA"
"cust_104","TX"
"cust_107","TX"
"cust_107","CA"
"cust_111","NV"
*/


WITH inq1 as (
SELECT *
FROM cards_ingest.tran_fact tf INNER JOIN lkp_data.lkp_state_details lkp ON tf.stat_cd = lkp.state_cd
),

inq2 as (
SELECT tran_date, stat_cd, count(distinct cust_id) as num_customers
FROM cards_ingest.tran_fact 
WHERE stat_cd is not NULL
GROUP BY tran_date, stat_cd
)

SELECT inq1.tran_date, inq2.stat_cd, inq2.num_customers, population_cnt-num_customers as promotion_target_cnt
FROM inq1 INNER JOIN inq2 on inq1.tran_date = inq2.tran_date AND inq1.stat_cd = inq2.stat_cd 
GROUP BY inq1.tran_date, inq2.stat_cd,inq2.num_customers, promotion_target_cnt
ORDER BY tran_date, stat_cd

/*OUTPUT:
"tran_date","stat_cd","num_customers","promotion_target_cnt"
"2022-01-01","CA","2","498"
"2022-01-01","NY","1","199"
"2022-01-01","TX","1","399"
"2022-01-03","NY","1","199"
"2022-01-04","CA","2","498"
"2022-01-05","TX","2","398"
"2022-02-01","NY","1","199"
"2022-02-03","NV","1","99"
"2022-02-03","NY","1","199"
"2022-02-03","TX","1","399"
"2022-02-05","CA","1","499"
"2022-02-05","TX","1","399"
"2022-03-01","CA","1","499"
"2022-03-02","CA","1","499"
"2022-04-01","CA","1","499"
"2022-07-03","NV","1","99"
*/
