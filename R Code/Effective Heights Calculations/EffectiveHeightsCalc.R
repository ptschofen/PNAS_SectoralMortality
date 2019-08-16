############################################################## 
#########  Effective Heights  ################################

setwd('...Effective Heights Calculations') #__#

library(beepr)
library(dplyr)

## Approach with smoke file
# read in data: file size is 2.3 GB and was obtained from EPA's FTP server
# Link: ftp://newftp.epa.gov/air/nei/2014/flat_files/
smoke<-read.csv('SmokeFlatFile_POINT_20160928.csv', 
                stringsAsFactors = F, skip=105)[,c(4, 12:14, 18:23)]
smoke<-subset(smoke, smoke$POLL=='PM25-PRI' | 
                smoke$POLL=='SO2' |
                smoke$POLL=='NOX' |
                smoke$POLL=='VOC' |
                smoke$POLL=='NH3')
colnames(smoke)[1]<-'eis'

# Converting to metric units
smoke$STKHGT<-smoke$STKHGT*.3048
smoke$STKDIAM<-smoke$STKDIAM*.3048
smoke$STKTEMP<-(smoke$STKTEMP-32)*5/9+273
smoke$STKFLOW<-smoke$STKFLOW*.3048^3
smoke$STKVEL<-smoke$STKVEL*.3048

# Remove observation with no STKHGT
smoke<-smoke[which(!(is.na(smoke$STKHGT))),]

# subsetting only tallest observation per facility  
smoke <- smoke %>% group_by(eis) %>%
  slice(which.max(STKHGT))

# save this file
write.csv(smoke, 'smoke_facilities.csv', row.names = F)
smoke<-read.csv('smoke_facilities.csv')

# subsetting only observations with all parameters (height, diameter, flow, velocity) there
smoke.allpar<-smoke[complete.cases(smoke[, c(5, 6, 7, 9)]),]

# anti-join by eis to reduce smoke
smoke<-anti_join(smoke, smoke.allpar, by='eis')

# remove observations with neither flow nor velocity
smoke<-smoke[-which(is.na(smoke$STKFLOW)&is.na(smoke$STKVEL)),]

# subset observations with flow but no velocity or no flow
smoke.novel<-smoke[!is.na(smoke$STKFLOW),]
#smoke.noflow<-smoke[!is.na(smoke$STKVEL),] # (there are none)

# Calculate velocity (q/(1/4*d^2*pi)) and flow (4*v*d^2*pi)
smoke.novel$STKVEL<-smoke.novel$STKFLOW/(0.25*smoke.novel$STKDIAM^2*pi)
#smoke.noflow$STKFLOW<-smoke.noflow$STKVEL*4*smoke.noflow$STKDIAM^2*pi

smoke.allpar$method<-'all parameters from smoke'
smoke.novel$method<-'some stack parameters computed'
#smoke.noflow$method<-'some stack parameters computed'

# bind together for effective height calculation
eff.height<-rbind(smoke.allpar, smoke.novel)

# Read in eis plus state file
fac.states<-read.csv('fac_states.csv')
fac.states<-fac.states %>% group_by(eis) %>% summarize(State=first(State),
                                                       FIPS=first(FIPS))

eff.height<-left_join(eff.height, fac.states, by='eis')

# read in weather data file
weather<-read.csv('Weather_Data.csv', stringsAsFactors = F)

# join the file to facilities
eff.height<-left_join(eff.height, weather, by='State')

# Calculate flux according to Turner (1994, p.3-2)
eff.height$FLUX<-9.8 * eff.height$STKVEL *eff.height$STKDIAM^2 * 
  (eff.height$STKTEMP-eff.height$Avg_K)/(4*eff.height$STKTEMP)

# Calculate s parameter (stability class) for Turner 1994
# assuming dT/dz = .001K/m and dry adiabatic lapse rate is .0098 K/m
eff.height$stab<-(9.8*.00198)/eff.height$Avg_K

# Calculate delta-H
eff.height$delta_H<-2.6*(eff.height$FLUX/(eff.height$u_bar*eff.height$stab))^(1/3)

# Effective Height
eff.height$eff_height<-eff.height$STKHGT+eff.height$delta_H


eff.height<-eff.height[, c('eis', 'FIPS', 'eff_height')]
eff.height[which(is.na(eff.height$eff_height)),]$eff_height<-0

eff.height$ap3.assignment<-NA
eff.height$easiur.assignment<-NA

for (i in 1:nrow(eff.height)){
  if(eff.height$eff_height[i]>=250){
    eff.height$ap3.assignment[i]<-'Medium'
  }else{eff.height$ap3.assignment[i]<-'Low'}
}

for (i in 1:nrow(eff.height)){
  if(eff.height$eff_height[i]>=75&eff.height$eff_height[i]<225){
    eff.height$easiur.assignment[i]<-'Med 150'
  }else if(eff.height$eff_height[i]>=225){eff.height$easiur.assignment[i]<-'Tall 300'}
  else{eff.height$easiur.assignment[i]<-'Area'}
}

setwd('.../PNAS_SectoralMortality')

write.csv(eff.height, 'eff_heights_2014.csv', row.names=F)
