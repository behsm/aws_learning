create table IF NOT EXISTS cards_ingest.cust_dim_details (
    cust_id varchar(10) encode zstd,
    state_cd varchar(2) encode zstd,
    zip_cd varchar(5) encode zstd,
    cust_first_name varchar(20) encode zstd,
    cust_last_name varchar(20) encode zstd,
    start_date date,
    end_date date,
    active_flag varchar(1) encode raw
);
