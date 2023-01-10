import psycopg2
import pandas as pd
from sqlalchemy import create_engine
from sqlachlemy.engine.url import url
from config import db 

engine = create_engine(url.create(
  db.drivername,
  username = db.username
  password = db.password
  host = db.hostname
  port = db.port
  database = db.database
))
 


def db_connect():
  
  conn = psycopg2.connect(
    host = db.hostname
    username = db.username
    password = db.password
    dbname = db.database,
    port = db.port
  )
  cur = conn.cursor()
  
  return cur, conn

def db_to_df(query: str):
  
  cur, conn = db_connect()
  sql_query = pd.read_sql_query(query, conn)
  df = pd.DataFrame(sql_query)
  cur.close()
  conn.close()
  return df
  
def 
  
