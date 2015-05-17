# this script performs spatial interpolations on the dataset´s last version (buffer)
# by using ´automap´ among other R libraries
# Alfredo Vásquez - Dec. 2014
library(sp)
library(rgdal)
library(lattice)
library(sqldf)
library(gstat)
library(tcltk)
library(maptools)
library(MASS)
library(ggplot2)
library(gridExtra)
library(raster)
require(plyr)
require(akima)

setwd('C:/Users/Alfredo/Documents/R/eind')
source('setLonLat_lastValues.R')

############################## Dataset ####################################
path="C:/data/"
fN = "lastVLonLat.csv"
fileNew = paste0(path,fN)
einDL <- read.csv(fileNew)

# this is a filter, I am discarding the sensors outside the city
einDL <- read.csv.sql(fileNew,sql="SELECT * FROM file WHERE lat >= 51.39 and lat <= 51.50 ")

# since log transform does not make any significant different 
# I am using the pm10 original values
einDL$PM10t <- (einDL$pm10)

qqnorm(einDL$pm10)
qqline(einDL$pm10, col=5)
hist(einDL$pm10,col=0,main="PM10 Concentration")
hist(log(einDL$pm10),col=0,main="Log PM10 Concentration")


######################## Coordinates ######################################

##set east and north coordinates
ed <- floor(einDL$east/100)
ems <- einDL$east - ed*100
lon <- ed + ems/60

nd <- floor(einDL$north/100)
nms <- einDL$north - nd*100
lat <- nd + nms/60

east_lon <- lon
north_lat <- lat
PM10t <- einDL$PM10t
plot(hist(PM10t))

eD2PM10<-rbind(east_lon,north_lat,PM10t)
eD1PM10<-data.frame(t(eD2PM10))  
# this is to filter the sensors that are outside Eindhoven
eD3PM10 <- subset(eD1PM10, north_lat >= 51.2)
eD3PM10 <- subset(eD3PM10, north_lat <= 52.2)

coordinates(eD3PM10) <- ~ east_lon + north_lat
# indicate the lat-long WGS84 CRS
proj4string(eD3PM10) = CRS("+init=epsg:4326")  
# transform to Ameersfort Grid system
einDPM10 = spTransform(eD3PM10, CRS("+init=epsg:28992")) 

einDgrid<-expand.grid(x=seq(157000, 165000, by=100), y=seq(377000,390000, by=100))
einDSpatialP <- SpatialPoints(einDgrid)
gridded(einDSpatialP) <- TRUE

########################## = Projections = ###############################
proj4string(einDSpatialP)<-proj4string(einDPM10)


################################ automap #########################################

library(automap)

# Ordinary kriging
kriging_result = autoKrige(PM10t~1, einDPM10, einDSpatialP)
plot(kriging_result,axes=TRUE)
summary(kriging_result)
kriging_result # to get the sserr

df <- data.frame(matrix(nrow=50,ncol=10)) #new data frame for predicted valeus
pred <- kriging_result$krige_output$var1.pred
#automapPlot(pred)

#k.outp <- as.data.frame(kriging_result$krige_output)
#head(k.outp)
#cb=data.frame(map("state",xlim=range(initial.df$lon),ylim=range(initial.df$lat),plot=F)[c("x","y")])

#str(kriging_result)
#kriging_result$sserr
#summary(kriging_result)
#kv = data.frame(kriging_result[[1]])
#head(kv)
#plot(kv$var1.pred)
#kp <- kriging_result$krige_output
#writeGDAL(kp["var1.pred"], "C:/data/rcgs/KrigingPred.asc")
#writeGDAL(kp["var1.var"], "C:/data/rcgs/KrigingVar.asc")
#summary(kp)
#plot(kriging_result$exp_var)
#plot(kriging_result$var_model)
#plot(kriging_result$krige_output)
#plot(kriging_result$krige_output$var1.pred,col=3)
#plot(kriging_result$krige_output$var1.var,col=2)
#plot(kriging_result$krige_output$var1.stdev,col=4)

#spplot(pm.ked2, "var", sp.layout=list("sp.points", pch="+", tmp5),main="KED Standard deviation of PM10",col.regions= terrain.colors(20, alpha=1))

#plot(k.outp["var1.pred"])
#summary(kp["pred"])
#summary(kp["var1.pred"])
#r=raster(kp["var1.pred"])
#r1=raster(pm.ked2["var"])
#output="r5.tif"
#output="r6.tif"
#output_wms="C:/data/rcgs/pm10.tif"
#writeRaster(r,output_wms,"GTiff",overwrite=TRUE)
#writeOGR(r, dsn = 'C:/data/rcgs', layer ='pm10', driver = 'ESRI Shapefile')
#writeOGR(kp["var1.pred"], dsn = 'C:/data/rcgs', layer = 'pm10_', driver = "ESRI Shapefile")
#writeRaster(r,output,"GTiff", overwrite=TRUE)
#writeRaster(r1,output,"GTiff", overwrite=TRUE)

################################ cross-validation ################################
#kriging_result$var
#kriging_result$var_model

cv.ok.auto <-krige.cv(PM10t~1,einDPM10,model=kriging_result$var,nfold=nrow(einDPM10))
summary(cv.ok.auto)
res.auto <- as.data.frame(cv.ok.auto)$residual
# ME
me.auto = mean(res.auto)
me.auto
# RMSE
rmse.auto = sqrt(mean(res.auto^2))
rmse.auto
# MSDR
msdr.auto = mean(res.auto^2/as.data.frame(cv.ok.auto)$var1.var)
msdr.auto
#rm(res)
#plot(cv.ok)



###### cross-validation diferences ###### 
#cv.diff <- data.frame(diff=cv.ok.inta$residual-cv.ok.auto$residual,
#                      better=(abs(cv.ok.inta$residual) < abs(cv.ok.auto$residual))
#)
#summary(cv.diff$diff)
#summary(cv.diff$better)

#d <- SpatialPointsDataFrame(coordinates(cv.ok.auto),data=as.data.frame(cv.diff$diff))
#bubble(d, 
#       col=c("lightblue","darkgreen"),
#       panel=function(x, ...){
#         panel.xyplot(x, ...);
#         panel.grid(h=-1, v=-1, col="darkgrey")
#       }
#)


#cV.diff <- cv.ok.inta$residual-cv.ok.auto$residual
#histogram(cV.diff, col="lightblue2", nint=12, type="count",
#          main="Cross-Validation errors", xlab="PM10, ppm")

