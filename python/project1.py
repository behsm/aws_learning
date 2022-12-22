import psycopg2
import pandas as pd
# Connect to database
#Change this to use an input file later
conn = psycopg2.connect("dbname=1218 user=postgres password=password")

# Open a cursor to perform database operations
cur = conn.cursor()
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
df["commission"] = df["tran_ammt"]*.4
print(df)






# Close communication with the database
cur.close()
conn.close()