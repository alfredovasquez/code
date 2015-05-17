# this script gets the pre-processed dataset (buffer), and upload it to the SOS-DB (simplified version)
# Edited by Alfredo: 14-01-2015

import datetime
import psycopg2

# Connect to an existing database
conn = psycopg2.connect("dbname=eindhoven user=postgres password=postgres")

# Open a cursor to perform database operations
cur = conn.cursor()

# this function performs the dataset uploading
def load_csv (file_name):
    # define the complete path
    path = "C:\\data\\"+file_name

    # copy data from CSV file to database table
    innerString='sensorId,pm1UgPerM3,pm25UgPerM3,pm10UgPerM3,notUsed,ozonUgPerM3,relHumPct,tempC'
    print innerString
    outerString = "COPY measurement ("+innerString+")FROM %s DELIMITERS ',' CSV HEADER;"
    print outerString
    sqlString = outerString
    fn = (path, )
    cur.execute(sqlString, fn)
    conn.commit()

    # update the database to set the date and time
    dString="current_date"
    innerString0 = 'mDate'
    sqlString0 = "UPDATE measurement SET "+innerString0+"="+dString+" WHERE "+innerString0+" IS NULL;"
    print(sqlString0)
    cur.execute(sqlString0)
    conn.commit()
    tString="current_time"
    innerString00 = 'mTime'
    sqlString00 = "UPDATE measurement SET "+innerString00+"="+tString+" WHERE "+innerString00+" IS NULL;"
    print(sqlString00)
    cur.execute(sqlString00)
    conn.commit()

# clean database
#sqlStringClean = "DELETE FROM measurement;"
#print(sqlStringClean)
#cur.execute(sqlStringClean)
#conn.commit()

# CALL THE FUNCTION
fileName= "last_upload.csv"
load_csv(fileName)

# Close communication with the database
cur.close()
conn.close()
