--Part 1
--1. show me all the tran_date,tran_ammt and total tansaction ammount per tran_date

SELECT tran_date, tran_ammt, SUM(tran_ammt)
OVER (PARTITION BY tran_date) as total_transaction_ammount
FROM cards_ingest.tran_fact

--2. show me all the tran_date,tran_ammt and total tansaction ammount per tran_date and rank of the transaction ammount desc within per tran_date
--Ouput:
--2022-01-01,7145.00,19543.00,1
--2022-01-01,6125.00,19543.00,2

SELECT tran_date, tran_ammt, SUM(tran_ammt)
OVER (PARTITION BY tran_date) as total_transaction_ammount,
ROW_NUMBER() over (PARTITION BY tran_date
				   ORDER BY tran_ammt desc)
FROM cards_ingest.tran_fact
ORDER BY tran_date

--3. show me all the fields and total tansaction ammount per tran_date and only 2nd rank of the transaction ammount desc within per tran_date
 --(Here you are using he question2 but filtering only for rank 2)
 
SELECT *
FROM ( 
	SELECT tran_date, tran_ammt, SUM(tran_ammt)
	OVER (PARTITION BY tran_date) as total_transaction_ammount,
	ROW_NUMBER() over (PARTITION BY tran_date
	ORDER BY tran_ammt desc) rownumber
FROM cards_ingest.tran_fact) inq
where rownumber = 2
ORDER BY tran_date


--Part 2

--1. Join tran_fact and cust_dim_details on cust_id and tran_dt between start_date and end_date

SELECT * 
FROM cards_ingest.tran_fact fact
INNER JOIN cards_ingest.cust_dim_details dim 
ON fact.cust_id = dim.cust_id AND fact.tran_date BETWEEN dim.start_date AND dim.end_date

--2. show me all the fields and total tansaction ammount per tran_date and only 2nd rank of the transaction
 --ammount desc within per tran_date(Here you are using he question2 but filtering only for rank 2) and join
  --cust_dim_details on cust_id and tran_dt between start_date and end_date
  
SELECT *
FROM ( 
	SELECT *, SUM(tran_ammt)
	OVER (PARTITION BY tran_date) as total_transaction_ammount,
	ROW_NUMBER() over (PARTITION BY tran_date
	ORDER BY tran_ammt desc) rownumber
	FROM cards_ingest.tran_fact fact
	INNER JOIN cards_ingest.cust_dim_details dim 
	ON fact.cust_id = dim.cust_id AND fact.tran_date BETWEEN dim.start_date AND dim.end_date
	) inq
WHERE rownumber = 2
ORDER BY tran_date

--3. From question 2 : when stat_cd is not euqal to state_cd then data issues else good data as stae_cd_status
 --[Note NUll from left side is not equal NUll from other side  >> means lets sayd NULL value from fact table if compared
 --to NULL Value to right table then it should be data issues]

SELECT *,
	CASE
	WHEN stat_cd != state_cd THEN 'data issues'
	WHEN stat_cd IS NULL THEN 'data issues'
	ELSE 'good data'
	END AS state_cd_status
FROM ( 
	SELECT *, SUM(tran_ammt)
	OVER (PARTITION BY tran_date) as total_transaction_ammount,
	ROW_NUMBER() over (PARTITION BY tran_date
	ORDER BY tran_ammt desc) rownumber
	FROM cards_ingest.tran_fact fact
	INNER JOIN cards_ingest.cust_dim_details dim 
	ON fact.cust_id = dim.cust_id AND fact.tran_date BETWEEN dim.start_date AND dim.end_date
	) inq
--WHERE rownumber = 2
ORDER BY tran_date
 
