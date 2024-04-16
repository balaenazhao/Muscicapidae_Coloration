library(raster)
library(dplyr)
library(ggplot2)
library(patchwork)

### get coordianates from tas data file
allbirds_tas<- read.csv("tas.combined.csv",header=T,sep=',')
temp_coor <- data.frame(allbirds_tas[,"decimalLongitude"],allbirds_tas[,"decimalLatitude"])

########################################################################
##################### exatract from annual variables ###################

temp_raster<- raster("CHELSA/CHELSA_bio1_1981-2010_V.2.1_temperature.tif")
temp <- extract(temp_raster,temp_coor,method='bilinear',df=TRUE)
temp$temperature <- temp$CHELSA_bio1_1981.2010_V.2.1_temperature * 0.1 - 273.15
bird_annual_temp<- data.frame(allbirds_tas[,"species"],temp_coor,temp$temperature)
temp_mean <- aggregate(bird_annual_temp[,4],list(bird_annual_temp[,1]),mean,na.rm=TRUE, na.action=na.pass)
colnames(temp_mean)[1] <- "species"
colnames(temp_mean)[2] <- "temperature"
write.csv(temp_mean, "Temperature_annual_mean.csv", row.names = FALSE)


####################### testing on two species ####################

#### resident bird Copsychus saularis
#### migratory bird Muscicapa sibirica

allbirds_tas<- read.csv("Occurrence_Data/tas.combined.csv",header=T,sep=',')
data1<- bird_annual_temp[bird_annual_temp[,1] == "Copsychus saularis" | bird_annual_temp[,1] == "Muscicapa sibirica",]
data2<- allbirds_tas[allbirds_tas$species == "Copsychus saularis" | allbirds_tas$species == "Muscicapa sibirica",]
data1$type<- "annual"
data2$type <- "monthly"
dat1<- select(data1,allbirds_tas....species..,temp.temperature,type)
colnames(dat1)[1]<- "species"
colnames(dat1)[2]<- "tas"

dat2<-select(data2,species,tas,type)
plot_dat<- rbind(dat1,dat2)
p1<- ggplot(plot_dat, aes(x=species, y=tas, fill=type)) + geom_boxplot() + scale_fill_manual(values = c("#0072B2", "#E69F00"))

#### plot mean values comparison across all species
df<- read.csv(file="Occurrence_Data/test_on_annual/test_on_annual.csv",header=T,sep=",")
p2<- ggplot(df, aes(x = move, y = temperature, fill=type)) + geom_boxplot() + scale_fill_manual(values = c("#0072B2", "#E69F00"))

pdf("./boxplot.pdf", width = 12, height = 5)
p1 + p2
dev.off()



