import psycopg2
import pandas as pd
from sqlalchemy import create_engine

# Connect to database
#Change this to use an input file later
conn = psycopg2.connect("dbname=1218 user=postgres password=password")
engine = create_engine('postgresql://postgres:password@localhost:5432/1218')
# Open a cursor to perform database operations
cur = conn.cursor()
conn.autocommit = True
sql_query = pd.read_sql_query(
    '''
    SELECT *
    FROM cards_ingest.tran_fact
    '''
    ,conn
)
df = pd.DataFrame(sql_query)
#print(df)
df["stat_cd"] = df["stat_cd"].fillna('TX')
#print(df)
df["commission"] = df.apply(lambda row: float(row.tran_ammt) * .4, axis=1)
df.reset_index(drop=True, inplace=True)
df.to_sql(name='tran_fact', schema='cards_ingest', con=engine, if_exists = 'replace')

print(f"NULL COUNT in df: {df.isna().sum().sum()}")
df2 = pd.DataFrame(sql_query)
print(len(df2) == len(df))

# Close communication with the database
cur.close()
conn.close()
engine.dispose()
