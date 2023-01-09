CREATE TABLE IF NOT EXISTS cards_ingest.tran_fact(
    tran_id int encode AZ64,
    cust_id varchar(10) encode raw, 
    stat_cd varchar(2) encode raw, 
    tran_ammt decimal(10,2) encode AZ64,
    tran_date date encode raw
) SORTKEY(tran_date);
