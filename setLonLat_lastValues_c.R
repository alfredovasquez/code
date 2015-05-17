# this script transforms the east-north into longitude-latitude coordinates 
# then creates a new CSV file to store the new version to be uploaded
# Alfredo Vásquez - Dec. 2014

library(sp)
library(rgdal)
library(lattice)
library(sqldf)
library(gstat)

# this function receives the names and paths of both the original file with east-north
# values and the new file which includes the longitude-latitude columns
addLonLat <- function(f,fN) {
  eD <- read.csv(f)
  ed <- floor(eD$east/100)
  ems <- eD$east - ed*100
  eD$lon <- ed + ems/60
  nd <- floor(eD$north/100)
  nms <- eD$north - nd*100
  eD$lat <- nd + nms/60
  write.csv(eD,file=fN,row.names=FALSE)
  return(eD)
}

path="C:/data/"
f = "last.csv"
fileName = paste0(path,f)

# raw data 
einD <- read.csv(fileName)

fNew = "lastVLonLat.csv"
fileNew = paste0(path,fNew)

# data with longitude latitude
einDL = addLonLat(fileName,fileNew)


# this file will be used to upload the last values to the table 'measurement'
#eData <- read.csv.sql(fileNew,sql="SELECT sensorId,ufp,ozon,pm10,pm1,pm25,relHum,tempC FROM file")
keep <- c("sensorId","pm1","pm25","pm10","ufp","ozon","relHum","tempC")
eData <- einDL[keep]

#head(eData)
fLoad = "last_upload.csv"
fileLoad = paste0(path,fLoad)
write.csv(eData,file=fileLoad,row.names=FALSE)
