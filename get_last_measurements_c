# this script gets the last measurements as an html file, then re-format it to write a CSV file with the same content
# Alfredo V?squez - Nov. 2014
import urllib
import urllib2
import csv

# url to find the last measurements as html
url="http://193.172.204.137:3011/api?airboxid=*"
data = urllib.urlopen(url)

# retrieved gets the html document
retrieved = data.read()
data.close()

# build a CSV file from the html in ?retrieved?

# ?clean? has the headers plus the content of ?retrieved?
clean = "sensorId,pm1,pm25,pm10,ufp,ozon,relHum,tempC,north,east"+"\n" + retrieved

# replace caracters in ?retrieved? to format the new CSV file
clean = clean.replace("<p>","")
clean = clean.replace("</p>","\n")
clean = clean.replace(".cal","")
clean = clean.replace(':',',')
clean = clean.replace('(',"")
clean = clean.replace(')',"")
print clean

# set the name and path for the new CSV file to store the content of ?clean?
file0 = "last.csv"
path = "C:\\data\\"
fileName = path +file0
f= open(fileName, "wb")
f.write(clean)
f.close()
