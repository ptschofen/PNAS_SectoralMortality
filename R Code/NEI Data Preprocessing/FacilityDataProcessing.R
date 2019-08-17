#### Section 1 - Read in Data
#### Section 2 - Prepare matrices for AP3 and tables for NAICS

## Load Packages, set working directory
library(dplyr)
library(tidyr)
library(foreign)
library(readstata13)

################## Section 1 ######################

setwd('...PNAS_SectoralMortality')

## Some useful groups
mds<-c('MD.NH3', 'MD.NOx', 'MD.PM25', 'MD.SO2', 'MD.VOC')
emi<-c('NH3', 'NOx', 'PM25', 'SO2', 'VOC')
ged<-c('GED.NH3', 'GED.NOx', 'GED.PM25', 'GED.SO2', 'GED.VOC')
year<-c(2008, 2011, 2014)

## Read in Nick's Tall and Tall 2 data, remove unneeded columns
tall<-read.dta13("Tall1_List_AP2.dta")[, 'eis']
tall<-as.data.frame(tall)
names(tall)<-'eis'

tall2<-read.dta13("Tall2_List_AP2_Update.dta")[, 'eisidentifier']
tall2<-as.data.frame(tall2)
names(tall2)<-"eis"

# Read in FIPS list AP3
fips<-read.csv('fips_apeep.csv')[,1:3]
names(fips)<-c('State', 'County', 'FIPS')

eff.heights<-read.csv('eff_heights_2014.csv')

for(k in 1:length(year)){
  setwd('...PNAS_SectoralMortality')
  ## Read in Data (from ftp://newftp.epa.gov/air/nei/2014/data_summaries/) etc
  ## Change column name from 'pollutant_desc' to 'description' where applicable
fac.1<-read.csv(paste('Raw Data/EPA/', year[k], '/process_12345.csv', sep=''),  ###
                stringsAsFactors = FALSE)
if(any(variable.names(fac.1)=='pollutant_desc')){
  names(fac.1)[names(fac.1) == "pollutant_desc"] <- "description"
}
fac.2<-read.csv(paste('Raw Data/EPA/', year[k], '/process_678910.csv', sep=''), ###
                stringsAsFactors = FALSE)
if(any(variable.names(fac.2)=='pollutant_desc')){
  names(fac.2)[names(fac.2) == "pollutant_desc"] <- "description"
}


## Remove unneeded columns
fac.1<-fac.1[, c('scc','eis_facility_site_id','description',
                 'county_name','state_and_county_fips_code',
                 'facility_site_name','naics_cd', 
                 'addr_state_cd', 'latitude_msr', 'longitude_msr', 'total_emissions')]
fac.2<-fac.2[, c('scc','eis_facility_site_id','description',
                 'county_name','state_and_county_fips_code',
                 'facility_site_name','naics_cd', 
                 'addr_state_cd', 'latitude_msr', 'longitude_msr', 'total_emissions')]

# Filter out criteria pollutants
fac.1.filtered <- fac.1 %>% 
  filter(description=="Sulfur Dioxide" |
           description=="Ammonia" |
           description=="Nitrogen Oxides" |
           description=="PM2.5 Primary (Filt + Cond)" |
           description=="Volatile Organic Compounds")

fac.2.filtered <- fac.2 %>% 
  filter(description=="Sulfur Dioxide" |
           description=="Ammonia" |
           description=="Nitrogen Oxides" |
           description=="PM2.5 Primary (Filt + Cond)" |
           description=="Volatile Organic Compounds")

rm(fac.1, fac.2)

# Merge the data sets
fac.comb<-rbind(fac.1.filtered, fac.2.filtered)
rm(fac.1.filtered, fac.2.filtered)

fac.comb$total_emissions<-as.numeric(fac.comb$total_emissions)

# Group by EIS and Pollutant
fac.grouped<- fac.comb %>%  
  group_by_at(vars(eis_facility_site_id, description)) %>%
  summarize(SCC=first(scc),
            County=first(county_name),
            FIPS=first(state_and_county_fips_code),
            Name=first(facility_site_name),
            NAICS=first(naics_cd),
            State=first(addr_state_cd),
            Lat=first(latitude_msr),
            Long=first(longitude_msr),
            Emissions=sum(total_emissions, na.rm=T))

# Spread pollutants to new columns
fac.all<-spread(fac.grouped, description, Emissions)

# Remove non-contiguous areas by FIPS code
# Creating a vector with every possible FIPS code for the 5 non-contiguous areas
AK<-2000:2999
AS<-60000:60999
HI<-15000:15999
PR<-72000:72999
VI<-78000:78999
rest<-c(85000:85999, 88000:88999)


non.cont<-as.data.frame(c(AK, AS, HI, PR, VI, rest))
colnames(non.cont)[1]<-"FIPS"
fac.cont<-anti_join(fac.all, non.cont)
names(fac.cont)[10:14]<-emi
rm(non.cont, fac.all, fac.comb, fac.grouped)

## Group by EIS ID
facilities<-fac.cont %>% group_by(eis_facility_site_id) %>%
  summarize(SCC=first(SCC),
            County=first(County),
            FIPS=first(FIPS),
            Name=first(Name),
            NAICS=first(NAICS),
            State=first(State),
            Lat=first(Lat),
            Long=first(Long),
            NH3=sum(NH3, na.rm=T),
            NOx=sum(NOx, na.rm=T),
            PM25=sum(PM25, na.rm=T),
            SO2=sum(SO2, na.rm=T),
            VOC=sum(VOC, na.rm=T))

rm(fac.cont)
names(facilities)[1]<-'eis'

# Change FIPS Codes for Miami-Dade and other counties
# Assign Miami-Dade to its former FIPS # 12025
facilities$FIPS[which(facilities$FIPS==12086)]<-12025

# Assign all 8014 emissions to 8013 (8014 didn't exist when SR matrices were created)
facilities$FIPS[which(facilities$FIPS==8014)]<-8013

# Throw all county emissions of counties that were merged into a bigger one into that one
facilities$FIPS[which(facilities$FIPS==51515)]<-51019
facilities$FIPS[which(facilities$FIPS==51560)]<-51005

# Change EIS ID of Armstrong Power Plant to correct number in Tall List for 2014
if(year[k]==2014){ facilities$eis[which(facilities$eis==3866811)]<-3865811}

setwd('...Desktop/PNAS_SectoralMortality')

## Write File
write.csv(facilities, paste(year[k], '_facilities.csv', sep=''), row.names = F)

######## Section 2
###### Continue from here for assignment to AP3 source types 
#######

## Assigning facilities for AP3
# Method of elimination: assign until nothing is left
facilities<-left_join(facilities, eff.heights, by=c('eis', 'FIPS'))

tall.ap3<-left_join(tall, facilities, by='eis')
facilities<-anti_join(facilities, tall.ap3, by='eis')
# If a facility has multiple generators/stacks, divide emissions evenly across them
tall.ap3<-tall.ap3 %>% group_by(eis) %>% mutate(n_fac=n())
tall.ap3$NH3[is.na(tall.ap3$NH3)]<-0
tall.ap3$NOx[is.na(tall.ap3$NOx)]<-0
tall.ap3$PM25[is.na(tall.ap3$PM25)]<-0
tall.ap3$SO2[is.na(tall.ap3$SO2)]<-0
tall.ap3$VOC[is.na(tall.ap3$VOC)]<-0
tall.ap3[, emi]<-tall.ap3[, emi]/tall.ap3$n_fac

tall2.ap3<-left_join(tall2, facilities, by='eis')
facilities<-anti_join(facilities, tall2.ap3, by='eis')
# If a facility has multiple generators/stacks, divide emissions evenly across them
tall2.ap3<-tall2.ap3 %>% group_by(eis) %>% mutate(n_fac=n())
tall2.ap3$NH3[is.na(tall2.ap3$NH3)]<-0
tall2.ap3$NOx[is.na(tall2.ap3$NOx)]<-0
tall2.ap3$PM25[is.na(tall2.ap3$PM25)]<-0
tall2.ap3$SO2[is.na(tall2.ap3$SO2)]<-0
tall2.ap3$VOC[is.na(tall2.ap3$VOC)]<-0
tall2.ap3[, emi]<-tall2.ap3[, emi]/tall2.ap3$n_fac

eff.heights.med<-eff.heights[which(eff.heights$ap3.assignment=='Medium'),]
medium.ap3<-inner_join(facilities, eff.heights.med)
facilities<-anti_join(facilities, medium.ap3)

# Change Four Corners Plant FIPS
if(any(facilities$Name=='Four Corners Power Plant')){
  facilities[which(facilities$Name=='Four Corners Power Plant'),]$FIPS<-35045
}
low.ap3<-facilities
mobile<-anti_join(low.ap3, fips, by='FIPS')
low.ap3<-anti_join(low.ap3, mobile)

# Assign FIPS codes to missing values by state
for (i in 1:nrow(mobile)){
  if(is.na(mobile$FIPS[i])&mobile$State[i]=='AZ'){
    mobile$FIPS[i]<-4777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='CO'){
    mobile$FIPS[i]<-21777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='MN'){
    mobile$FIPS[i]<-27777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='ID'){
    mobile$FIPS[i]<-16777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='MT'){
    mobile$FIPS[i]<-30777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='NM'){
    mobile$FIPS[i]<-35777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='UT'){
    mobile$FIPS[i]<-49777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='NE'){
    mobile$FIPS[i]<-31777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='WA'){
    mobile$FIPS[i]<-53777
  } else if(is.na(mobile$FIPS[i])&mobile$State[i]=='KS'){
    mobile$FIPS[i]<-20777}
}

# Assign states to mobile FIPS codes
for (i in 1:nrow(mobile)){
  if(mobile$FIPS[i]==4777){
    mobile$State[i]<-'AZ'}
  else if(mobile$FIPS[i]==8777){
    mobile$State[i]<-'CO'}
  else if(mobile$FIPS[i]==12777){
    mobile$State[i]<-'FL'}
  else if(mobile$FIPS[i]==16777){
    mobile$State[i]<-'ID'}
  else if(mobile$FIPS[i]==20777){
    mobile$State[i]<-'KS'}
  else if(mobile$FIPS[i]==21777){
    mobile$State[i]<-'KY'}
  else if(mobile$FIPS[i]==26777){
    mobile$State[i]<-'MI'}
  else if(mobile$FIPS[i]==27777){
    mobile$State[i]<-'MN'}
  else if(mobile$FIPS[i]==32777){
    mobile$State[i]<-'NV'}
  else if(mobile$FIPS[i]==30777){
    mobile$State[i]<-'MT'}
  else if(mobile$FIPS[i]==32777){
    mobile$State[i]<-'NV'}
  else if(mobile$FIPS[i]==35777){
    mobile$State[i]<-'NM'}
  else if(mobile$FIPS[i]==39777){
    mobile$State[i]<-'OH'}
  else if(mobile$FIPS[i]==48777){
    mobile$State[i]<-'TX'}
  else if(mobile$FIPS[i]==49777){
    mobile$State[i]<-'UT'}
  else if(mobile$FIPS[i]==53777){
    mobile$State[i]<-'WA'}
  else if(mobile$FIPS[i]==55777){
    mobile$State[i]<-'WI'}
}

mobile.ap3<-mobile %>% group_by(State) %>% summarize(NH3=sum(NH3, na.rm=T),
                                                     NOx=sum(NOx, na.rm=T),
                                                     PM25=sum(PM25, na.rm=T),
                                                     SO2=sum(SO2, na.rm=T),
                                                     VOC=sum(VOC, na.rm=T))

# Group mobile by states, then add them to states file to distribute
low.ap3.cont<-low.ap3 %>% group_by(State) %>% mutate(NOx.statesum=sum(NOx), na.rm=T) 

low.ap3.cont<- low.ap3.cont %>% group_by(FIPS) %>% 
  summarize(State=first(State),
            NH3=sum(NH3, na.rm=T),
            NOx=sum(NOx, na.rm=T),
            PM25=sum(PM25, na.rm=T),
            SO2=sum(SO2, na.rm=T),
            VOC=sum(VOC, na.rm=T),
            NOx.statesum=first(NOx.statesum))

low.ap3.cont$NOx.fraction<-NA
for(i in 1:nrow(low.ap3.cont)){
  low.ap3.cont$NOx.fraction[i]<-low.ap3.cont$NOx[i]/low.ap3.cont$NOx.statesum[i]
}
sum(low.ap3.cont$NOx.fraction)

nox.fraction<-low.ap3.cont[, c('FIPS', 'NOx.fraction')]

mobile.assignment<-left_join(fips, mobile.ap3, by='State')

mobile.assignment<-left_join(mobile.assignment, nox.fraction, by='FIPS')

# Assign 0 to NOx fractions not included in low.ap3.cont
mobile.assignment[is.na(mobile.assignment)]<-0

# multiply with nox fractions to get correct emission amounts
mobile.assignment[, emi]<-mobile.assignment[, emi]*mobile.assignment$NOx.fraction

# Create Data files for all stack types
tall.ap3<-tall.ap3[, c(emi)]
tall2.ap3<-tall2.ap3[, c(emi)]
medium.ap3<-medium.ap3 %>% group_by(FIPS) %>% summarize(NH3=sum(NH3, na.rm=T),
                                                        NOx=sum(NOx, na.rm=T),
                                                        PM25=sum(PM25, na.rm=T),
                                                        SO2=sum(SO2, na.rm=T),
                                                        VOC=sum(VOC, na.rm=T))
medium.ap3<-left_join(fips[3], medium.ap3)
medium.ap3[is.na(medium.ap3)]<-0

low.ap3<-low.ap3 %>% group_by(FIPS) %>% summarize(NH3=sum(NH3, na.rm=T),
                                                  NOx=sum(NOx, na.rm=T),
                                                  PM25=sum(PM25, na.rm=T),
                                                  SO2=sum(SO2, na.rm=T),
                                                  VOC=sum(VOC, na.rm=T))
low.ap3<-rbind(mobile.assignment[, c('FIPS', emi)], low.ap3)
low.ap3<-low.ap3 %>% group_by(FIPS) %>% summarize(NH3=sum(NH3, na.rm=T),
                                                  NOx=sum(NOx, na.rm=T),
                                                  PM25=sum(PM25, na.rm=T),
                                                  SO2=sum(SO2, na.rm=T),
                                                  VOC=sum(VOC, na.rm=T))



# Empty columns for AP3
tall.ap3$empty<-0
tall2.ap3$empty<-0
medium.ap3$empty<-0
low.ap3$empty<-0

tall.ap3<-tall.ap3[, c('NH3', 'NOx', 'empty', 'PM25', 'SO2', 'VOC')]
tall2.ap3<-tall2.ap3[, c('NH3', 'NOx', 'empty', 'PM25', 'SO2', 'VOC')]
medium.ap3<-medium.ap3[, c('NH3', 'NOx', 'empty', 'PM25', 'SO2', 'VOC')]
low.ap3<-low.ap3[, c('NH3', 'NOx', 'empty', 'PM25', 'SO2', 'VOC')]

# Write files
write.table(tall.ap3, sep=",",  col.names=FALSE, paste('tall_', year[k], '.csv',
                                                       sep=''), row.names=F)
write.table(tall2.ap3, sep=",",  col.names=FALSE, paste('tall2_', year[k], '.csv',
                                                        sep=''), row.names=F)
write.table(medium.ap3, sep=",",  col.names=FALSE, paste('medium_', year[k], '.csv',
                                                         sep=''), row.names=F)
write.table(low.ap3, sep=",",  col.names=FALSE, paste('low_', year[k], '.csv',
                                                      sep=''), row.names=F)
write.csv(mobile, paste('mobile_', year[k], '.csv', sep=''), row.names=F)

rm(eff.heights.med, facilities, low.ap3, low.ap3.cont)
rm(medium.ap3, mobile, mobile.ap3, mobile.assignment, nox.fraction)
rm(tall.ap3, tall2.ap3)
rm(AK, AS, HI, PR, VI)
}