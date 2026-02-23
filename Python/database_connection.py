
# ============================================================
# IPL Performance Analysis
# Database Connection File
#
# This script establishes connection between Python and
# MS SQL Server database so that query results can be
# loaded into pandas for visualization.
# ============================================================

import pyodbc
from sqlalchemy import create_engine


# ----- SQL Server Details -----
SERVER = "localhost"
DATABASE = "IPL Analysis DB"
DRIVER = "ODBC Driver 17 for SQL Server"


# Windows Authentication Connection String
connection_string = f"mssql+pyodbc://@{SERVER}/{DATABASE}?driver={DRIVER}&trusted_connection=yes"


# Create Engine
try:
    engine = create_engine(connection_string)
    print("Connection Successful")

except Exception as e:
    print("Connection Failed")
    print(e)



from sqlalchemy import text

# Test connection (runs only when this file executed directly)
if __name__ == "__main__":
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT DB_NAME()"))
            for row in result:
                print("Connected to:", row[0])
    except Exception as e:
        print("Test failed:", e)
