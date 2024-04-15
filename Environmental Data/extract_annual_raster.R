library(raster)
library(dplyr)
library(ggplot2)
library(patchwork)

### get coordianates from tas data file
allbirds_tas<- read.csv("tas.combined.csv",header=T,sep=',')
allbirds_pr<- read.csv("pr.combined.csv",header=T,sep=',')
bird_coor <- data.frame(allbirds_tas[,"lon"],allbirds_tas[,"lat"])

########################################################################
##################### exatract from annual variables ###################

temp_raster<- raster("CHELSA/CHELSA_bio1_1981-2010_V.2.1_temperature.tif")
rain_raster<- raster("CHELSA/CHELSA_bio12_1981-2010_V.2.1_precipitation.tif")

temp <- extract(temp_raster,bird_coor,method='bilinear',df=TRUE)
temp$temperature <- temp$CHELSA_bio1_1981.2010_V.2.1_temperature * 0.1 - 273.5
rain <- extract(rain_raster,bird_coor,method='bilinear',df=TRUE)
rain$precipitation <- rain$CHELSA_bio12_1981.2010_V.2.1_precipitation * 0.1
bird_annual_Data<- data.frame(allbirds_tas[,"species"],bird_coor,temp$temperature,rain$precipitation)

#### calculate mean values for all birds
temp_mean <- aggregate(bird_annual_Data[,5],list(bird_annual_Data$species),mean,na.rm=TRUE, na.action=na.pass)
precip_mean <- aggregate(bird_annual_Data[,6],list(bird_annual_Data$species),mean,na.rm=TRUE, na.action=na.pass)
colnames(temp_mean)[1] <- "species"
colnames(temp_mean)[2] <- "temperature"
colnames(precip_mean)[1] <- "species"
colnames(precip_mean)[2] <- "precipitation"
write.csv(temp_mean, "Temperature_annual_mean.csv", row.names = FALSE)
write.csv(precip_mean, "Precipitation_annual_mean.csv", row.names = FALSE)

####################### testing on two species ####################

#### resident bird Copsychus saularis
data1<- bird_annual_Data[bird_annual_Data$species == "Copsychus saularis",]
data2<- allbirds_tas[allbirds_tas$species == "Copsychus saularis",]
data1$type<- "annual"
data2$type <- "monthly"
dat1<- select(data1,temp.temperature,rain.precipitation,type)
colnames(dat1)[1]<- "tas"
colnames(dat1)[2]<- "pr"
dat2<-select(data2,tas,pr,type)
plot_dat1<- rbind(dat1,dat2)
p1<- ggplot(plot_dat, aes(x=type, y=tas)) + geom_boxplot()
p2<- ggplot(plot_dat, aes(x=type, y=pr)) + geom_boxplot()

#### migratory bird Muscicapa sibirica
data3<- bird_annual_Data[bird_annual_Data$species == "Muscicapa sibirica",]
data4<- allbirds_tas[allbirds_tas$species == "Muscicapa sibirica",]
data3$type<- "annual"
data4$type <- "monthly"
dat3<- select(data3,temp.temperature,rain.precipitation,type)
colnames(dat3)[1]<- "tas"
colnames(dat4)[2]<- "pr"
dat4<-select(data4,tas,pr,type)
plot_dat2<- rbind(dat3,dat4)
p3<- ggplot(plot_dat2, aes(x=type, y=tas)) + geom_boxplot()
p4<- ggplot(plot_dat2, aes(x=type, y=pr)) + geom_boxplot()

#### plot mean values comparison across all species
tas_mean<- read.csv("Tas_Mean_Data.csv",header=T,sep=',')
df<- merge(temp_mean,tas_mean,by="species")
p5<- ggplot(df, aes(x = species)) + 
  geom_line(aes(x = species, y = temperature), color="blue", size=2) + 
  geom_line(aes(x = species, y = temperature), color="red", size=2)


