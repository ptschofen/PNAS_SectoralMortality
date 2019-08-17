#### To make script work, change file paths at lines marked with ###

## This file requires to manually change the year for each NEI year.
## Lines where this is required are marked with '##'
## Further, a variable name in the EPA files changed from 2011 to 2014, see below
### !!! In 2014, the variable with pollutant name changed from  ####
### !!! 'description' to 'pollutant_desc')            !!! ####

## Section 1 - Read in EPA Data
## Section 2 - Steps required for .csv file for NAICS script GED_Calcs.R
## Section 3 - Creating Area Sources input file for AP3 Matlab

## Load Packages, set working directory
library(dplyr)
library(tidyr)
library(data.table)

##--------------------- Section 1- different procedures for different years -----##
## Procedure for 2011 and 2014

setwd('...PNAS_SectoralMortality/')

## Files were downloaded from ftp://newftp.epa.gov/air/nei/2014/data_summaries/ in July 2018 
## 
nonpoint<-read.csv('Raw Data/EPA/2014/nonpoint.csv', stringsAsFactors = FALSE) ###

#
onroad.123<-read.csv('Raw Data/EPA/2014/onroad_123.csv', stringsAsFactors = FALSE) ###
onroad.4<-read.csv('Raw Data/EPA/2014/onroad_4.csv', stringsAsFactors = FALSE) ###
onroad.5<-read.csv('Raw Data/EPA/2014/onroad_5.csv', stringsAsFactors = FALSE) ###
onroad.67<-read.csv('Raw Data/EPA/2014/onroad_67.csv', stringsAsFactors = FALSE) ###
onroad.8910<-read.csv('Raw Data/EPA/2014/onroad_8910.csv', stringsAsFactors = FALSE) ###

### Merge into summary files, remove subfiles
onroad<-rbind(onroad.123, onroad.4, onroad.5, onroad.67, onroad.8910)

rm(onroad.123, onroad.4, onroad.5, onroad.67, onroad.8910)

## Sort columns alphabetically, remove some unneeded ones
nonpoint<-nonpoint[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]
nonpoint<-nonpoint[, order(names(nonpoint))]
onroad<-onroad[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]
onroad<-onroad[, order(names(onroad))]

# Same process, but for much larger nonroad files
# repeating sequential steps for each subfile because of large file size
#
nonroad.123<-read.csv('Raw Data/EPA/2014/nonroad_123.csv', stringsAsFactors = FALSE) ###
nonroad.123<-nonroad.123[, order(names(nonroad.123))]
nonroad.123<-nonroad.123[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]

#
nonroad.4<-read.csv('Raw Data/EPA/2014/nonroad_4.csv', stringsAsFactors = FALSE) ###
nonroad.4<-nonroad.4[, order(names(nonroad.4))]
nonroad.4<-nonroad.4[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]

#
nonroad.5<-read.csv('Raw Data/EPA/2014/nonroad_5.csv', stringsAsFactors = FALSE) ###
nonroad.5<-nonroad.5[, order(names(nonroad.5))]
nonroad.5<-nonroad.5[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]

#
nonroad.67<-read.csv('Raw Data/EPA/2014/nonroad_67.csv', stringsAsFactors = FALSE) ###
nonroad.67<-nonroad.67[, order(names(nonroad.67))]
nonroad.67<-nonroad.67[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]

#
nonroad.8910<-read.csv('Raw Data/EPA/2014/nonroad_8910.csv', stringsAsFactors = FALSE) ###
nonroad.8910<-nonroad.8910[, order(names(nonroad.8910))]
nonroad.8910<-nonroad.8910[, c('county_name', "state_and_county_fips_code", 'scc', 'pollutant_desc', 'total_emissions')]

nonroad<-rbind(nonroad.123, nonroad.4, nonroad.5, nonroad.67, nonroad.8910)
nonroad<-nonroad[, order(names(nonroad))]

rm(nonroad.123, nonroad.4, nonroad.5, nonroad.67, nonroad.8910)

names(onroad)<-c('county_name', 'description', 'scc', 
                 'state_and_county_fips_code', 'total_emissions')
names(nonroad)<-c('county_name', 'description', 'scc', 
                 'state_and_county_fips_code', 'total_emissions')
names(nonpoint)<-c('county_name', 'description', 'scc', 
                 'state_and_county_fips_code', 'total_emissions')
##---------------- Section 1 end ----------------------------------##


## Section 2

setwd('...PNAS_SectoralMortality')

## Filter out pollutants of interest, group by SCC&Pollutant&FIPS, group, condense and
## create new columns for each pollutant
nonpoint.grouped<- nonpoint %>% 
  filter(description=="Sulfur Dioxide" |
           description=="Ammonia" |
           description=="Nitrogen Oxides" |
           description=="PM2.5 Primary (Filt + Cond)" |
           description=="Volatile Organic Compounds")


onroad.grouped<- onroad %>% 
  filter(description=="Sulfur Dioxide" |
           description=="Ammonia" |
           description=="Nitrogen Oxides" |
           description=="PM2.5 Primary (Filt + Cond)" |
           description=="Volatile Organic Compounds")

nonroad.grouped<- nonroad %>% 
  filter(description=="Sulfur Dioxide" |
           description=="Ammonia" |
           description=="Nitrogen Oxides" |
           description=="PM2.5 Primary (Filt + Cond)" |
           description=="Volatile Organic Compounds")

## Merge the files
area.sources<-rbind(nonpoint.grouped, nonroad.grouped, onroad.grouped)
rm(nonpoint, nonroad, onroad)
rm(nonpoint.grouped, nonroad.grouped, onroad.grouped)
names(area.sources)[4]="FIPS"
names(area.sources)[3]='SCC'

## Remove non-contiguous areas by FIPS code and tribal emissions
# Creating a vector with every possible FIPS code for the 5 non-contiguous areas
# plus water areas and whatever 88xxx code is
AK<-2000:2999
AS<-60000:60999
HI<-15000:15999
PR<-72000:72999
VI<-78000:78999
rest<-c(85000:85999, 88000:88999)

non.cont<-as.data.frame(c(AK, AS, HI, PR, VI, rest))
colnames(non.cont)[1]<-"FIPS"
area.sources<-anti_join(area.sources, non.cont)

rm(non.cont, AK, AS, HI, PR, VI, rest)

# Save the raw area sources file
write.csv(area.sources, 'area_sources_2014_raw.csv', row.names = F) ###

## ------------------------------------------------------------- ## 

area.sources<-read.csv('area_sources_2014_raw.csv') ###

# create checksum
checksum<-sum(area.sources$total_emissions)

# Join in SCC Definitions to sort out biogenic VOC emissions
# SCC List is from https://ofmpub.epa.gov/sccwebservices/sccsearch/

scc.list.full<-read.csv('SCC_List.csv', stringsAsFactors = F)
scc.list<-scc.list.full[, c('Code', 'sector.text')]
names(scc.list)<-c('SCC', 'sector.text')
scc.list$SCC<-as.numeric(scc.list$SCC)

area.sources.all<-left_join(area.sources, scc.list)

# Total Emissions
area.sources.total<-area.sources.all %>% group_by_at(vars(
  county_name, description, SCC, FIPS, sector.text)) %>%
  summarize(emissions=sum(total_emissions, na.rm=T))

area.sources.total<-spread(area.sources.total, description, emissions)
area.sources.total<-area.sources.total[c('SCC', 'FIPS', 'county_name', 'sector.text',
                                     'Ammonia', 'Nitrogen Oxides', 'PM2.5 Primary (Filt + Cond)',
                                     'Sulfur Dioxide', 'Volatile Organic Compounds')]
names(area.sources.total)<-c("SCC", "FIPS", "County", "sector.text", "NH3_T", 
                           "NOx_T", "PM25_T", "SO2_T", "VOC_T")

# Assign Miami-Dade to its former FIPS # 12025
area.sources.total$FIPS[which(area.sources.total$FIPS==12086)]<-12025

# Assign all 8014 emissions to 8013 (8014 didn't exist when SR matrices were created)
area.sources.total$FIPS[which(area.sources.total$FIPS==8014)]<-8013

# Throw all county emissions of counties that were merged into a bigger one into that one
area.sources.total$FIPS[which(area.sources.total$FIPS==51515)]<-51019
area.sources.total$FIPS[which(area.sources.total$FIPS==51560)]<-51005

write.csv(area.sources.total, 'area_sources_for_NAICS_2014.csv', row.names = F) ###

##---------------- Section 2 end ----------------------------------##


## Section 3
area.sources.VOCbio<-area.sources.all[which(area.sources.all$sector.text=='Biogenics - Vegetation and Soil'&area.sources.all$description=='Volatile Organic Compounds'),]
area.sources.VOCbio$description<-'VOC_B'

area.sources.all<-area.sources.all[-which(area.sources.all$sector.text=='Biogenics - Vegetation and Soil'&area.sources.all$description=='Volatile Organic Compounds'),]

area.sources.all<-rbind(area.sources.all, area.sources.VOCbio)
rm(area.sources.total, area.sources.VOCbio)

area.sources.total<-area.sources.all %>% group_by_at(vars(
  county_name, description, SCC, FIPS, sector.text)) %>%
  summarize(emissions=sum(total_emissions, na.rm=T))

area.sources.total<-spread(area.sources.total, description, emissions)

area.sources.total<-area.sources.total[, c('FIPS', 'Ammonia', 'Nitrogen Oxides', 
                                           'PM2.5 Primary (Filt + Cond)', 'Sulfur Dioxide', 
                                           'VOC_B', 'Volatile Organic Compounds')]
names(area.sources.total)<-c('FIPS', 'NH3', 'NOx', 'PM25', 'SO2', 'VOC_B', 'VOC_A')

area.sources.total<-area.sources.total %>% group_by(FIPS) %>% ###
  summarize(NH3_T=sum(NH3, na.rm=T),
            NOx_T=sum(NOx, na.rm=T),
            PM25_T=sum(PM25, na.rm=T),
            SO2_T=sum(SO2, na.rm=T),
            VOC_A=sum(VOC_A, na.rm=T),
            VOC_B=sum(VOC_B, na.rm=T))

area.sources.total<-area.sources.total[order(area.sources.total$FIPS),]

area.sources<-as.data.frame(cbind(area.sources.total$FIPS,
                                       area.sources.total$NH3_T, 
                         area.sources.total$NOx_T,
                         rep(0, length(nrow(area.sources.total))),
                         area.sources.total$PM25_T,
                         area.sources.total$SO2_T,
                         area.sources.total$VOC_A,
                         area.sources.total$VOC_B,
                         rep(0, length(nrow(area.sources.total))),
                         rep(0, length(nrow(area.sources.total))),
                         rep(0, length(nrow(area.sources.total)))))
colnames(area.sources)<-c('FIPS', 'NH3_T', 'NOx_T', 'PM10_T', 'PM25_T', 'SO2_T', 
                               'VOC_A', 'VOC_B', 'PM25_B', 'PM25_A', 'last')


# Assign Miami-Dade to its former FIPS # 12025
area.sources$FIPS[which(area.sources$FIPS==12086)]<-12025

# Assign all 8014 emissions to 8013 (8014 didn't exist when SR matrices were created)
area.sources$FIPS[which(area.sources$FIPS==8014)]<-8013

# Throw all county emissions of counties that were merged into a bigger one into that one
area.sources[which(area.sources$FIPS==51515)]<-51019
area.sources[which(area.sources$FIPS==51560)]<-51005

# Adding back in counties that are now part of a bigger county as 0s
area.sources.counties<-rbind(c(51515, rep(0, 10)), c(51560, rep(0, 10)))
as.data.frame(area.sources.counties)
colnames(area.sources.counties)<-c('FIPS', 'NH3_T', 'NOx_T', 'PM10_T', 'PM25_T', 'SO2_T', 
                                   'VOC_A', 'VOC_B', 'PM25_B', 'PM25_A', 'last')
area.sources<-rbind(area.sources, area.sources.counties)
rm(area.sources.counties)

# Summarize by FIPS
area.sources<-area.sources %>% group_by(FIPS) %>% 
  summarize(NH3_T=sum(NH3_T, na.rm=T),
            NOx_T=sum(NOx_T, na.rm=T),
            PM10_T=sum(PM10_T, na.rm=T),
            PM25_T=sum(PM25_T, na.rm=T),
            SO2_T=sum(SO2_T, na.rm=T),
            VOC_A=sum(VOC_A, na.rm=T),
            VOC_B=sum(VOC_B, na.rm=T),
            PM25_B=sum(PM25_B, na.rm=T),
            PM25_A=sum(PM25_A, na.rm=T),
            last=sum(last, na.rm=T))

# Sort by FIPS
area.sources.final<-area.sources[order(area.sources$FIPS),]

rm(area.sources.all, area.sources, scc.list, scc.list.full, area.sources.total)

area.sources.final<-area.sources.final[-1]

if(abs(sum(area.sources.final[, 1:10])-checksum)< 5){beep(3)}else{beep(9)}

write.table(area.sources.final, sep=",",  col.names=FALSE, file='area_sources_2014.csv',
            row.names=F) ###
