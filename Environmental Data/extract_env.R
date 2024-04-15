library(raster)
library(dplyr)

data<- read.csv("Muscicapidae_occurrences_data.csv",header=TRUE,sep='\t')

########################################################################
################### separate occurrence by month-year ##################

# create combinations of month and year
years <- c()
months <- c()
for (year in 1990:2019) {
  for (month in 1:12) {
    years <- c(years, year)
    months <- c(months, month)
  }
}
month_list <- data.frame(Year = years, Month = months)

################### Loop through each combination ##################
################ filter rows based on the combination ##############
count(month_list)  #360
for (i in 1:360) {
  combination <- month_list[i,]
  filtered_rows <- data %>%
    filter(month == combination$Month & year == combination$Year)
  monthyear_data<- select(filtered_rows,species,decimalLatitude,decimalLongitude,month,year)
  distinct_data <- distinct(monthyear_data)
  filename <- paste0("occurrence_", combination$Month, "_", combination$Year, ".csv")
  write.csv(distinct_data, file = filename, row.names = FALSE)
}

########################################################################
################### extract temperature by month avg ###################

### loop through all years for all month
for (j in 1:12) {
  for (i in 1990:2019) {
  ras_name <- paste0("CHELSA/tas/CHELSA_tas_",sprintf("%02d",j),"_", i, "_V.2.1.tif")
  tas <- raster(ras_name)
  occur_name<- paste0("occurrence_",j,"_", i, ".csv")
  records<- read.csv(occur_name, header=T,sep=',')
  coordinates<- data.frame(records[,"decimalLongitude"],records[,"decimalLatitude"])
  value <- extract(tas,coordinates,method='bilinear',df=TRUE)
  value$temperature <- value[,2] * 0.1 - 273.5
  extracted_data <- data.frame(records,value$temperature)
  new_file_name <- paste0("tas_",sprintf("%02d",j),"/tas_",sprintf("%02d",j),"_", i, "_data.csv")
  write.csv(extracted_data, new_file_name, row.names = FALSE)
  }
}


####################### extract precipitation data #########################

### loop through all years for all month
for (j in 1:12) {
  for (i in 1990:2018) {
    ras_name <- paste0("CHELSA/pr/CHELSA_pr_",sprintf("%02d",j),"_", i, "_V.2.1.tif")
    pr <- raster(ras_name)
    occur_name<- paste0("Occurrence_Data/month/occurrence_",j,"_", i, ".csv")
    records<- read.csv(occur_name, header=T,sep=',')
    coordinates<- data.frame(records[,"decimalLongitude"],records[,"decimalLatitude"])
    value <- extract(pr,coordinates,method='bilinear',df=TRUE)
    value$precip <- value[,2] * 0.1
    extracted_data <- data.frame(records,value$precip)
    new_file_name <- paste0("Occurrence_Data/pr_data/pr_",sprintf("%02d",j),"/pr_",sprintf("%02d",j),"_", i, "_data.csv")
    write.csv(extracted_data, new_file_name, row.names = FALSE)
  }
}

#### a seprate loop for 2019 because it only has six months data
for (j in 1:6) {
    ras_name <- paste0("CHELSA/pr/CHELSA_pr_0",j,"_2019_V.2.1.tif")
    pr <- raster(ras_name)
    occur_name<- paste0("Occurrence_Data/month/occurrence_",j,"_2019.csv")
    records<- read.csv(occur_name, header=T,sep=',')
    coordinates<- data.frame(records[,"decimalLongitude"],records[,"decimalLatitude"])
    value <- extract(pr,coordinates,method='bilinear',df=TRUE)
    value$precip <- value[,2] * 0.1
    extracted_data <- data.frame(records,value$precip)
    new_file_name <- paste0("Occurrence_Data/pr_data/pr_0",j,"/pr_0",j,"_2019_data.csv")
    write.csv(extracted_data, new_file_name, row.names = FALSE)
}

########################################################################
##################### calculate tas and pr mean values ###################
allbirds_tas<- read.csv("tas.combined.csv",header=T,sep=',')
allbirds_pr <- read.csv("pr.combined.csv",header=T,sep=',')
tas_mean <- aggregate(allbirds_tas[,6],list(allbirds_tas$species),mean,na.rm=TRUE, na.action=na.pass)
pr_mean <- aggregate(allbirds_pr[,6],list(allbirds_pr$species),mean,na.rm=TRUE, na.action=na.pass)
colnames(tas_mean)[1] <- "species"
colnames(tas_mean)[2] <- "temperature"
colnames(pr_mean)[1] <- "species"
colnames(pr_mean)[2] <- "precipitation"
write.csv(tas_mean, "Tas_Mean_Data.csv", row.names = FALSE)
write.csv(pr_mean, "Pr_Mean_Data.csv", row.names = FALSE)


########################################################################
####################### extract elevation data #########################
elev_raster <- raster("geoData/mn30_grd/mn30_grd/")
all_coor<- select(data,species,decimalLatitude,decimalLongitude)
all_coor_uniq<- distinct(all_coor)
coors<- data.frame(all_coor_uniq[,"decimalLongitude"],all_coor_uniq[,"decimalLatitude"])
elev <- extract(elev_raster,coors,method='bilinear',df=TRUE)
elev_data <- data.frame(all_coor_uniq,elev$mn30_grd)
elev_mean <- aggregate(elev_data[,4],list(elev_data$species),mean,na.rm=TRUE, na.action=na.pass)
colnames(elev_mean)[1] <- "species"
colnames(elev_mean)[2] <- "elevation"
write.csv(elev_mean, "Elevation_Mean_Data.csv", row.names = FALSE)
