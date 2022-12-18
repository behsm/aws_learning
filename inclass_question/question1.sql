--1. Calculate total tran_ammt (sum) for each state

SELECT stat_cd, SUM(tran_ammt) AS total_tran_ammt
FROM cards_ingest.tran_fact
GROUP BY stat_cd

--2. Calculate maximum and minimum tran_ammt on each state and tran_date

SELECT stat_cd, tran_date, MIN(tran_ammt), MAX(tran_ammt)
FROM cards_ingest.tran_fact
GROUP BY stat_cd, tran_date
ORDER BY stat_cd, tran_date

--The order by is optional but it increases clarity when attempting to
--read the resulting table, if this table is only used internally then exclude order by

--3. Calculate total transaction which have tran_ammt more than 10000

SELECT COUNT(tran_id)
FROM cards_ingest.tran_fact
WHERE tran_ammt > 10000


--4. Show the state which have total (sum) tran_ammt more than 10000

SELECT stat_cd FROM 
	(SELECT stat_cd, SUM(tran_ammt) AS total_transaction
	 FROM cards_ingest.tran_fact
	 GROUP BY stat_cd) inq
WHERE inq.total_transaction > 10000



--5. show me the states where total ammt is more than 10000
--What's supposed to be different between question 4 and 5?
--isn't total tran_ammt the same as total_ammt

SELECT stat_cd FROM 
	(SELECT stat_cd, SUM(tran_ammt) AS total_transaction
	 FROM cards_ingest.tran_fact
	 GROUP BY stat_cd) inq
WHERE inq.total_transaction > 10000

--6. show me the states where cust_id ='cust_104' and  total ammt is more than 10000

SELECT stat_cd 
FROM cards_ingest.tran_fact
WHERE cust_id = 'cust_104'
GROUP BY stat_cd
HAVING SUM(tran_ammt) > 10000

--7. Calculate total transaction by state [ if state if NULL make it TX] where total transaction is more than 10000
SELECT stat_cd, total_transaction FROM 
	(SELECT COALESCE(stat_cd, 'TX')as stat_cd, SUM(tran_ammt) AS total_transaction
	 FROM cards_ingest.tran_fact
	 GROUP BY stat_cd) inq
WHERE inq.total_transaction > 10000
--8. Show me a message col if state is null then "missing data" else "good data"

SELECT *, 
CASE
	WHEN stat_cd IS NULL THEN 'data issues'
	ELSE 'good data'
END AS state_cd_status
FROM cards_ingest.tran_fact;


--9. Show me sum of tran_ammt by state [ if state is null and cust_id='cust_104' then 'TX' else 'CA']
SELECT stat_cd, SUM(total_transaction) FROM 
	(SELECT 
	 CASE
	 WHEN cust_id = 'cust_104' THEN COALESCE(stat_cd,'TX')
	 ELSE COALESCE(stat_cd, 'CA')
	 END as stat_cd, SUM(tran_ammt) AS total_transaction
	 FROM cards_ingest.tran_fact
	 GROUP BY stat_cd, cust_id) inq
GROUP BY stat_cd



--Join Question:

--1.Give me all details from transaction tale and zip_cd from dimension table.

SELECT fct.*, dim.zip_cd 
FROM cards_ingest.tran_fact fct
INNER JOIN cards_ingest.cust_dim_details dim ON fct.cust_id = dim.cust_id

--2. Sum of tran_ammt by zip_cd

SELECT zip_cd, SUM(tran_ammt) AS total_tran_ammt
FROM cards_ingest.tran_fact fct
INNER JOIN cards_ingest.cust_dim_details dim ON fct.cust_id = dim.cust_id
GROUP BY zip_cd

--3. Give me top 5 customer [ (first name+ last name) is customer] by tran_ammt [highest is first] join on cust_id

SELECT customer, SUM(tran_ammt) 
FROM
(
	SELECT CONCAT(cust_first_name,' ', cust_last_name) as Customer,
		fct.*
	FROM cards_ingest.tran_fact fct
	INNER JOIN cards_ingest.cust_dim_details dim ON fct.cust_id = dim.cust_id
) inq
GROUP BY inq.customer LIMIT 5


--4. Give me the all cols from tran_fact [ I don't need state_cd is null] first five records [ lower to highest]
--lower to higher in terms of state totals?

SELECT *, SUM(tran_ammt) OVER (PARTITION BY state_cd) as state_total
FROM 
(
SELECT * 
FROM cards_ingest.tran_fact fct
INNER JOIN cards_ingest.cust_dim_details dim ON fct.cust_id = dim.cust_id
WHERE dim.state_cd IS NOT NULL
) inq
ORDER BY state_total LIMIT 5
