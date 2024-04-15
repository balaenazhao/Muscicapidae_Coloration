library(raster)
library(dplyr)
library(ggplot2)
library(patchwork)

# run below scripts in bash
#cat tas_*/* > tas.combined.csv
#grep "Muscicapa sibirica" tas.combined.csv > Muscicapa_sibirica_tas.csv
#grep "Copsychus saularis" tas.combined.csv > Copsychus_saularis_tas.csv

########################################################################
##################### exatract from annual variables ###################

temp_raster<- raster("CHELSA/CHELSA_bio1_1981-2010_V.2.1_temperature.tif")
rain_raster<- raster("CHELSA/CHELSA_bio12_1981-2010_V.2.1_precipitation.tif")

#### resident bird Copsychus_saularis
Copsychus_saularis<- read.csv("Copsychus_saularis_tas.csv",header=T,sep=',')
bird_coor <- data.frame(Copsychus_saularis[,"lon"],Copsychus_saularis[,"lat"])
temp <- extract(temp_raster,bird_coor,method='bilinear',df=TRUE)
temp$temperature <- temp$CHELSA_bio1_1981.2010_V.2.1_temperature * 0.1 - 273.5
rain <- extract(rain_raster,bird_coor,method='bilinear',df=TRUE)
rain$precipitation <- rain$CHELSA_bio12_1981.2010_V.2.1_precipitation * 0.1
bird_Data<- data.frame(bird_coor,temp$temperature,rain$precipitation)
write.csv(bird_Data,file = "Copsychus_saularis_Annual_Data.csv")

#### migratory bird Muscicapa_sibirica
Muscicapa_sibirica<- read.csv("Muscicapa_sibirica_tas.csv",header=T,sep=',')
bird_coor <- data.frame(Muscicapa_sibirica[,"lon"],Muscicapa_sibirica[,"lat"])
temp <- extract(temp_raster,bird_coor,method='bilinear',df=TRUE)
temp$temperature <- temp$CHELSA_bio1_1981.2010_V.2.1_temperature * 0.1 - 273.5
rain <- extract(rain_raster,bird_coor,method='bilinear',df=TRUE)
rain$precipitation <- rain$CHELSA_bio12_1981.2010_V.2.1_precipitation * 0.1
bird_Data<- data.frame(bird_coor,temp$temperature,rain$precipitation)
write.csv(bird_Data,file = "Muscicapa_sibirica_Annual_Data.csv")

##################### use temperature as example ###################
#### plot boxplots
data1<- read.csv(file="Copsychus_saularis_Annual_Data.csv",header=T)
data2<- read.csv(file="Copsychus_saularis_tas.csv",header=T)
data1$type<- "annual"
data2$type <- "monthly"
dat1<- select(data1,temp.temperature,type)
colnames(dat1)[1]<- "temp"
dat2<-select(data2,temp,type)
plot_dat<- rbind(dat1,dat2)
p1<- ggplot(plot_dat, aes(x=type, y=temp)) + geom_boxplot()

data3<- read.csv(file="Muscicapa_sibirica_Annual_Data.csv",header=T)
data4<- read.csv(file="Muscicapa_sibirica_tas.csv",header=T)
data3$type<- "annual"
data4$type <- "monthly"
dat3<- select(data3,temp.temperature,type)
colnames(dat3)[1]<- "temp"
dat4<-select(data4,temp,type)
plot_dat2<- rbind(dat3,dat4)
p2<- ggplot(plot_dat2, aes(x=type, y=temp)) + geom_boxplot()

pdf("./boxplot.pdf", width = 8, height = 8)
p1 + p2
dev.off()
