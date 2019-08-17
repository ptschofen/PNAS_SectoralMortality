setwd('...PNAS_SectoralMortality')

## Load Packages, set working directory
library(beepr)
library(dplyr)
library(tidyr)

year<-c('2008', '2011', '2014')

for (k in 1:3){
  print(k)
# Read in Data from CDC Files (2 separate files because 85+ age group needs seperate download)
mort<-read.csv(paste('Mortality 5yr ', year[k], '.txt', sep=''), sep = '\t',
               stringsAsFactors = F)

mort<-mort[, c('X2013.Urbanization.Code', 'Census.Region', 'State', 'County.Code',
               'Five.Year.Age.Groups', 'Crude.Rate')]
names(mort)<-c('Urb.Code', 'Region', 'State', 'FIPS', 'Age.Group', 'Crude.Rate')

mort.85plus<-read.csv(paste('Mortality 85plus ', year[k], '.txt', sep=''), sep = '\t',
                      stringsAsFactors = F)

mort.85plus<-mort.85plus[, c('X2013.Urbanization.Code', 'Census.Region', 'State',
                             'County.Code', 'Ten.Year.Age.Groups', 'Crude.Rate')]
names(mort.85plus)<-c('Urb.Code', 'Region', 'State', 'FIPS', 'Age.Group', 'Crude.Rate')

mort<-rbind(mort, mort.85plus)
rm(mort.85plus)

mort<-mort[-which(mort$Age.Group=='100+ years' |
                    mort$Age.Group=='95-99 years' |
                    mort$Age.Group=='85-89 years' |
                    mort$Age.Group=='90-94 years' |
                    mort$Age.Group=='Not Stated'),]
if(k==4){mort<-mort[-which(is.na(mort$Urb.Code)),]}

mort$Urban<-NA
for (i in 1:nrow(mort)){
  if(mort[i, 'Urb.Code']>4){
    mort$Urban[i]<-0
  }else{mort$Urban[i]<-1}
}
mort<-mort[,-which(names(mort) %in% 'Urb.Code')]

# Remove text after crude rate, make numeric, get into right format
mort$Crude.Rate<-gsub("[^0-9\\.]", "", mort$Crude.Rate) 
mort$Crude.Rate<-as.numeric(mort$Crude.Rate)
mort$Crude.Rate<-mort$Crude.Rate/10^5

mort<-spread(mort, Age.Group, Crude.Rate)

# Remove non-contiguous areas
## Creating a vector with every possible FIPS code for the 5 non-contiguous areas
AK<-2000:2999
AS<-60000:60999
HI<-15000:15999
PR<-72000:72999
VI<-78000:78999
rest<-c(85000:85999, 88000:88999)

non.cont<-as.data.frame(c(AK, AS, HI, PR, VI, rest))
colnames(non.cont)[1]<-"FIPS"
mort<-anti_join(mort, non.cont)
rm(non.cont, AK, AS, HI, PR, VI, rest)

## Change FIPS coding to AP format
# Assign Miami-Dade to its former FIPS # 12025
mort$FIPS[which(mort$FIPS==12086)]<-12025

# Assign all 8014 values to 8013 (8014 didn't exist when AP3 matrices were created)
mort$FIPS[which(mort$FIPS==8014)]<-8013

# Sort columns
mort<-mort[, c('Region', 'State', 'FIPS', 'Urban', '< 1 year', '1-4 years', '5-9 years',
               '10-14 years', '15-19 years', '20-24 years', '25-29 years', '30-34 years',
               '35-39 years', '40-44 years', '45-49 years', '50-54 years', '55-59 years',
               '60-64 years ', '65-69 years', '70-74 years', '75-79 years', '80-84 years', 
               '85+ years')]

# Rename
names(mort)<- c('Region', 'State', 'FIPS', 'Urban',
                'age.less1', 'age.1.4', 'age.5.9', 'age.10.14', 'age.15.19',
                'age.20.24', 'age.25.29', 'age.30.34', 
                'age.35.39', 'age.40.44', 'age.45.49', 'age.50.54', 'age.55.59', 
                'age.60.64', 'age.65.69', 'age.70.74', 'age.75.79', 
                'age.80.84', 'age.more85')

# group to merge 8014 and 8013 (now both 8013)
mort<-mort %>% group_by(FIPS) %>% 
  summarize(Region=first(Region),
            State=first(State),
            Urban=first(Urban),
            age.less1=mean(age.less1, na.rm=T),
            age.1.4=mean(age.1.4, na.rm=T),
            age.5.9=mean(age.5.9, na.rm=T),
            age.10.14=mean(age.10.14, na.rm=T),
            age.15.19=mean(age.15.19, na.rm=T),
            age.20.24=mean(age.20.24, na.rm=T),
            age.25.29=mean(age.25.29, na.rm=T),
            age.30.34=mean(age.30.34, na.rm=T),
            age.35.39=mean(age.35.39, na.rm=T),
            age.40.44=mean(age.40.44, na.rm=T),
            age.45.49=mean(age.45.49, na.rm=T),
            age.50.54=mean(age.50.54, na.rm=T),
            age.55.59=mean(age.55.59, na.rm=T),
            age.60.64=mean(age.60.64, na.rm=T),
            age.65.69=mean(age.65.69, na.rm=T),
            age.70.74=mean(age.70.74, na.rm=T),
            age.75.79=mean(age.75.79, na.rm=T),
            age.80.84=mean(age.80.84, na.rm=T),
            age.more85=mean(age.more85, na.rm=T))

# Same procedure with state data from CDC
mort.state<-read.csv(paste('Mortality State 5yr ', year[k], '.txt', sep=''), sep = '\t',
               stringsAsFactors = F)

mort.state<-mort.state[, c('X2013.Urbanization.Code', 'State', 
               'Five.Year.Age.Groups', 'Crude.Rate')]
names(mort.state)<-c('Urb.Code', 'State', 'Age.Group', 'Crude.Rate')

mort.state.85plus<-read.csv(paste('Mortality State 85plus ', year[k], '.txt', sep=''), sep = '\t',
                      stringsAsFactors = F)

mort.state.85plus<-mort.state.85plus[, c('X2013.Urbanization.Code', 'State',
                             'Ten.Year.Age.Groups', 'Crude.Rate')]
names(mort.state.85plus)<-c('Urb.Code', 'State', 'Age.Group', 'Crude.Rate')

mort.state<-rbind(mort.state, mort.state.85plus)
rm(mort.state.85plus)

mort.state<-mort.state[-which(mort.state$Age.Group=='100+ years' |
                    mort.state$Age.Group=='95-99 years' |
                    mort.state$Age.Group=='85-89 years' |
                    mort.state$Age.Group=='90-94 years' |
                    mort.state$Age.Group=='Not Stated' |
                    mort.state$Age.Group==''),]

mort.state$Urban<-NA
for (i in 1:nrow(mort.state)){
  if(mort.state[i, 'Urb.Code']>4){
    mort.state$Urban[i]<-0
  }else{mort.state$Urban[i]<-1}
}
mort.state<-mort.state[,-which(names(mort.state) %in% 'Urb.Code')]

# Remove text after crude rate, make numeric, get into right format
mort.state$Crude.Rate<-gsub("[^0-9\\.]", "", mort.state$Crude.Rate) 
mort.state$Crude.Rate<-as.numeric(mort.state$Crude.Rate)
mort.state$Crude.Rate<-mort.state$Crude.Rate/10^5

mort.state<-mort.state %>% group_by_at(vars(State, Urban, Age.Group)) %>% summarize(
  Crude.Rate=mean(Crude.Rate, na.rm=T))

mort.state<-spread(mort.state, Age.Group, Crude.Rate)

# Sort columns
mort.state<-mort.state[, c('State', 'Urban', '< 1 year', '1-4 years', '5-9 years',
               '10-14 years', '15-19 years', '20-24 years', '25-29 years', '30-34 years',
               '35-39 years', '40-44 years', '45-49 years', '50-54 years', '55-59 years',
               '60-64 years ', '65-69 years', '70-74 years', '75-79 years', '80-84 years', 
               '85+ years')]

# Rename
names(mort.state)<- c('State', 'Urban',
                'st.age.less1', 'st.age.1.4', 'st.age.5.9', 'st.age.10.14', 'st.age.15.19',
                'st.age.20.24', 'st.age.25.29', 'st.age.30.34', 
                'st.age.35.39', 'st.age.40.44', 'st.age.45.49', 'st.age.50.54', 
                'st.age.55.59', 
                'st.age.60.64', 'st.age.65.69', 'st.age.70.74', 'st.age.75.79', 
                'st.age.80.84', 'st.age.more85')

# Same procedure for regional data
mort.region<-read.csv(paste('Mortality Region 5yr ', year[k], '.txt', sep=''), sep = '\t',
                     stringsAsFactors = F)

mort.region<-mort.region[, c('X2013.Urbanization.Code', 'Census.Region', 
                           'Five.Year.Age.Groups', 'Crude.Rate')]
names(mort.region)<-c('Urb.Code', 'Region', 'Age.Group', 'Crude.Rate')

mort.region.85plus<-read.csv(paste('Mortality Region 85plus ', year[k], '.txt', sep=''), sep = '\t',
                            stringsAsFactors = F)

mort.region.85plus<-mort.region.85plus[, c('X2013.Urbanization.Code', 'Census.Region',
                                         'Ten.Year.Age.Groups', 'Crude.Rate')]

names(mort.region.85plus)<-c('Urb.Code', 'Region', 'Age.Group', 'Crude.Rate')

mort.region<-rbind(mort.region, mort.region.85plus)
rm(mort.region.85plus)

mort.region<-mort.region[-which(mort.region$Age.Group=='100+ years' |
                                mort.region$Age.Group=='95-99 years' |
                                mort.region$Age.Group=='85-89 years' |
                                mort.region$Age.Group=='90-94 years' |
                                mort.region$Age.Group=='Not Stated' |
                                mort.region$Age.Group==''),]

mort.region$Urban<-NA
for (i in 1:nrow(mort.region)){
  if(mort.region[i, 'Urb.Code']>4){
    mort.region$Urban[i]<-0
  }else{mort.region$Urban[i]<-1}
}
mort.region<-mort.region[,-which(names(mort.region) %in% 'Urb.Code')]

# Remove text after crude rate, make numeric, get into right format
mort.region$Crude.Rate<-gsub("[^0-9\\.]", "", mort.region$Crude.Rate) 
mort.region$Crude.Rate<-as.numeric(mort.region$Crude.Rate)
mort.region$Crude.Rate<-mort.region$Crude.Rate/10^5

mort.region<-mort.region %>% group_by_at(vars(Region, Urban, Age.Group)) %>% summarize(
  Crude.Rate=mean(Crude.Rate, na.rm=T))

mort.region<-spread(mort.region, Age.Group, Crude.Rate)

# Sort columns
mort.region<-mort.region[, c('Region', 'Urban', '< 1 year', '1-4 years', '5-9 years',
                           '10-14 years', '15-19 years', '20-24 years', '25-29 years', '30-34 years',
                           '35-39 years', '40-44 years', '45-49 years', '50-54 years', '55-59 years',
                           '60-64 years ', '65-69 years', '70-74 years', '75-79 years', '80-84 years', 
                           '85+ years')]

# Rename
names(mort.region)<- c('Region', 'Urban',
                      're.age.less1', 're.age.1.4', 're.age.5.9', 're.age.10.14', 're.age.15.19',
                      're.age.20.24', 're.age.25.29', 're.age.30.34', 
                      're.age.35.39', 're.age.40.44', 're.age.45.49', 're.age.50.54', 
                      're.age.55.59', 
                      're.age.60.64', 're.age.65.69', 're.age.70.74', 're.age.75.79', 
                      're.age.80.84', 're.age.more85')


# Same procedure for national data
mort.nation<-read.csv(paste('Mortality Nation 5yr ', year[k], '.txt', sep=''), sep = '\t',
                      stringsAsFactors = F)

mort.nation<-mort.nation[, c('X2013.Urbanization.Code', 
                             'Five.Year.Age.Groups', 'Crude.Rate')]
names(mort.nation)<-c('Urb.Code', 'Age.Group', 'Crude.Rate')

mort.nation.85plus<-read.csv(paste("Mortality Nation 85plus ", year[k], ".txt", sep=""), 
                             sep = '\t',  stringsAsFactors = F)

mort.nation.85plus<-mort.nation.85plus[, c('X2013.Urbanization.Code',
                                           'Ten.Year.Age.Groups', 'Crude.Rate')]

names(mort.nation.85plus)<-c('Urb.Code', 'Age.Group', 'Crude.Rate')

mort.nation<-rbind(mort.nation, mort.nation.85plus)
rm(mort.nation.85plus)

mort.nation<-mort.nation[-which(mort.nation$Age.Group=='100+ years' |
                                  mort.nation$Age.Group=='95-99 years' |
                                  mort.nation$Age.Group=='85-89 years' |
                                  mort.nation$Age.Group=='90-94 years' |
                                  mort.nation$Age.Group=='Not Stated' |
                                  mort.nation$Age.Group==''),]

mort.nation$Urban<-NA
for (i in 1:nrow(mort.nation)){
  if(mort.nation[i, 'Urb.Code']>4){
    mort.nation$Urban[i]<-0
  }else{mort.nation$Urban[i]<-1}
}
mort.nation<-mort.nation[,-which(names(mort.nation) %in% 'Urb.Code')]

# Remove text after crude rate, make numeric, get into right format
mort.nation$Crude.Rate<-gsub("[^0-9\\.]", "", mort.nation$Crude.Rate) 
mort.nation$Crude.Rate<-as.numeric(mort.nation$Crude.Rate)
mort.nation$Crude.Rate<-mort.nation$Crude.Rate/10^5

mort.nation<-mort.nation %>% group_by_at(vars(Urban, Age.Group)) %>% summarize(
  Crude.Rate=mean(Crude.Rate, na.rm=T))

mort.nation<-spread(mort.nation, Age.Group, Crude.Rate)

# Sort columns
mort.nation<-mort.nation[, c('Urban', '< 1 year', '1-4 years', '5-9 years',
                             '10-14 years', '15-19 years', '20-24 years', '25-29 years', '30-34 years',
                             '35-39 years', '40-44 years', '45-49 years', '50-54 years', '55-59 years',
                             '60-64 years ', '65-69 years', '70-74 years', '75-79 years', '80-84 years', 
                             '85+ years')]

# Rename
names(mort.nation)<- c('Urban',
                       'us.age.less1', 'us.age.1.4', 'us.age.5.9', 'us.age.10.14', 
                       'us.age.15.19',
                       'us.age.20.24', 'us.age.25.29', 'us.age.30.34', 
                       'us.age.35.39', 'us.age.40.44', 'us.age.45.49', 'us.age.50.54', 
                       'us.age.55.59', 
                       'us.age.60.64', 'us.age.65.69', 'us.age.70.74', 'us.age.75.79', 
                       'us.age.80.84', 'us.age.more85')

mort.full<-left_join(mort, mort.state, by=c('State', 'Urban'))
mort.full<-left_join(mort.full, mort.region, by=c('Region', 'Urban'))
mort.full<-left_join(mort.full, mort.nation, by='Urban')

# Missing VA counties for 2016
if(k==4){missing1<-c(51515, rep(0, 79))
missing2<-c(51560, rep(0, 79))
mort.full<-rbind(mort.full, missing1, missing2)
mort.full<-mort.full[order(mort.full$FIPS),]}

# Make final dataframe
mort.final<-data.frame(matrix(NA, 3109, 19))
# Ages 0-24
for (j in 0:5){
  for(i in 1:nrow(mort.final)){
    if(is.na(mort.full[i, 5+j])==F){
      mort.final[i, j+1]<-mort.full[i, 5+j]}
    else if(is.na(mort.full[i, 24+j])==F){
      mort.final[i, j+1]<-mort.full[i, 24+j]}
    else if(is.na(mort.full[i, 43+j])==F){
      mort.final[i, j+1]<-mort.full[i, 43+j]}
    else{mort.final[i, j+1]<-mort.full[i, 62+j]}
  }
}

# Age 25-29 
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.25.29'])==F){
    mort.final[i,7]<-mort.full[i, 'age.25.29']}
  else if(is.na(mort.full[i, 'st.age.25.29'])==F){
    mort.final[i,7]<-mort.full[i, 'st.age.25.29']}
  else if(is.na(mort.full[i, 're.age.25.29'])==F){
    mort.final[i,7]<-mort.full[i, 're.age.25.29']}
  else{mort.final[i,7]<-mort.full[i,'us.age.25.29']}
}

# Age 30-34 
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.30.34'])==F){
    mort.final[i,8]<-mort.full[i, 'age.30.34']}
  else if(is.na(mort.full[i, 'st.age.30.34'])==F){
    mort.final[i,8]<-mort.full[i, 'st.age.30.34']}
  else if(is.na(mort.full[i, 're.age.30.34'])==F){
    mort.final[i,8]<-mort.full[i, 're.age.30.34']}
  else{mort.final[i,8]<-mort.full[i,'us.age.30.34']}
}

# Age 35-39
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.35.39'])==F){
    mort.final[i,9]<-mort.full[i, 'age.35.39']}
  else if(is.na(mort.full[i, 'st.age.35.39'])==F){
    mort.final[i,9]<-mort.full[i, 'st.age.35.39']}
  else if(is.na(mort.full[i, 're.age.35.39'])==F){
    mort.final[i,9]<-mort.full[i, 're.age.35.39']}
  else{mort.final[i,9]<-mort.full[i,'us.age.35.39']}
}

# Age 40-44
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.40.44'])==F){
    mort.final[i,10]<-mort.full[i, 'age.40.44']}
  else if(is.na(mort.full[i, 'st.age.40.44'])==F){
    mort.final[i,10]<-mort.full[i, 'st.age.40.44']}
  else if(is.na(mort.full[i, 're.age.40.44'])==F){
    mort.final[i,10]<-mort.full[i, 're.age.40.44']}
  else{mort.final[i,10]<-mort.full[i,'us.age.40.44']}
}

# Age 45-49
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.45.49'])==F){
    mort.final[i,11]<-mort.full[i, 'age.45.49']}
  else if(is.na(mort.full[i, 'st.age.45.49'])==F){
    mort.final[i,11]<-mort.full[i, 'st.age.45.49']}
  else if(is.na(mort.full[i, 're.age.45.49'])==F){
    mort.final[i,11]<-mort.full[i, 're.age.45.49']}
  else{mort.final[i,11]<-mort.full[i,'us.age.45.49']}
}

# Age 50-54
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.50.54'])==F){
    mort.final[i,12]<-mort.full[i, 'age.50.54']}
  else if(is.na(mort.full[i, 'st.age.50.54'])==F){
    mort.final[i,12]<-mort.full[i, 'st.age.50.54']}
  else if(is.na(mort.full[i, 're.age.50.54'])==F){
    mort.final[i,12]<-mort.full[i, 're.age.50.54']}
  else{mort.final[i,12]<-mort.full[i,'us.age.50.54']}
}

# Age 55-59
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.55.59'])==F){
    mort.final[i,13]<-mort.full[i, 'age.55.59']}
  else if(is.na(mort.full[i, 'st.age.55.59'])==F){
    mort.final[i,13]<-mort.full[i, 'st.age.55.59']}
  else if(is.na(mort.full[i, 're.age.55.59'])==F){
    mort.final[i,13]<-mort.full[i, 're.age.55.59']}
  else{mort.final[i,13]<-mort.full[i,'us.age.55.59']}
}

# Age 60-64
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.60.64'])==F){
    mort.final[i,14]<-mort.full[i, 'age.60.64']}
  else if(is.na(mort.full[i, 'st.age.60.64'])==F){
    mort.final[i,14]<-mort.full[i, 'st.age.60.64']}
  else if(is.na(mort.full[i, 're.age.60.64'])==F){
    mort.final[i,14]<-mort.full[i, 're.age.60.64']}
  else{mort.final[i,14]<-mort.full[i,'us.age.60.64']}
}

# Age 65-69
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.65.69'])==F){
    mort.final[i,15]<-mort.full[i, 'age.65.69']}
  else if(is.na(mort.full[i, 'st.age.65.69'])==F){
    mort.final[i,15]<-mort.full[i, 'st.age.65.69']}
  else if(is.na(mort.full[i, 're.age.65.69'])==F){
    mort.final[i,15]<-mort.full[i, 're.age.65.69']}
  else{mort.final[i,15]<-mort.full[i,'us.age.65.69']}
}

# Age 70-74
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.70.74'])==F){
    mort.final[i,16]<-mort.full[i, 'age.70.74']}
  else if(is.na(mort.full[i, 'st.age.70.74'])==F){
    mort.final[i,16]<-mort.full[i, 'st.age.70.74']}
  else if(is.na(mort.full[i, 're.age.70.74'])==F){
    mort.final[i,16]<-mort.full[i, 're.age.70.74']}
  else{mort.final[i,16]<-mort.full[i,'us.age.70.74']}
}

# Age 75-79
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.75.79'])==F){
    mort.final[i,17]<-mort.full[i, 'age.75.79']}
  else if(is.na(mort.full[i, 'st.age.75.79'])==F){
    mort.final[i,17]<-mort.full[i, 'st.age.75.79']}
  else if(is.na(mort.full[i, 're.age.75.79'])==F){
    mort.final[i,17]<-mort.full[i, 're.age.75.79']}
  else{mort.final[i,17]<-mort.full[i,'us.age.75.79']}
}

# Age 80-84
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.80.84'])==F){
    mort.final[i,18]<-mort.full[i, 'age.80.84']}
  else if(is.na(mort.full[i, 'st.age.80.84'])==F){
    mort.final[i,18]<-mort.full[i, 'st.age.80.84']}
  else if(is.na(mort.full[i, 're.age.80.84'])==F){
    mort.final[i,18]<-mort.full[i, 're.age.80.84']}
  else{mort.final[i,18]<-mort.full[i,'us.age.80.84']}
}

# Age 85+
for (i in 1:nrow(mort.final)){
  if(is.na(mort.full[i, 'age.more85'])==F){
    mort.final[i,19]<-mort.full[i, 'age.more85']}
  else if(is.na(mort.full[i, 'st.age.more85'])==F){
    mort.final[i,19]<-mort.full[i, 'st.age.more85']}
  else if(is.na(mort.full[i, 're.age.more85'])==F){
    mort.final[i,19]<-mort.full[i, 're.age.more85']}
  else{mort.final[i,19]<-mort.full[i,'us.age.more85']}
}

setwd('...Desktop/PNAS_SectoralMortality')
write.table(mort.final, sep=",",  col.names=FALSE, paste('mort_', year[k], '.csv',
                                                       sep=''), row.names=F)
}
beep(2)