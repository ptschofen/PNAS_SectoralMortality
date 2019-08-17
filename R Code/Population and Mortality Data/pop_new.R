# Set working directory

setwd('C:/Users/ptsch/Desktop/PNAS_SectoralMortality')

# Load Packages
library(dplyr)
library(tidyr)

pop<-read.csv('PEP_2017_PEPAGESEX_with_ann.csv', skip=1)
pop.2011<-pop[,c(2, 3, 13, 43, 43+30, 43+2*30, 43+3*30, 43+4*30, 43+5*30, 
                 43+6*30, 43+7*30, 43+8*30, 43+9*30, 43+10*30, 43+11*30, 
                 43+12*30, 43+13*30, 43+14*30, 43+15*30, 43+16*30, 43+17*30)]
pop.2014<-pop[,c(2, 3, 22, 52, 52+30, 52+2*30, 52+3*30, 52+4*30, 52+5*30, 
                 52+6*30, 52+7*30, 52+8*30, 52+9*30, 52+10*30, 52+11*30, 
                 52+12*30, 52+13*30, 52+14*30, 52+15*30, 52+16*30, 52+17*30)]

colnames(pop.2011)<-c('FIPS', 'County', 'total.pop', 'age.0.4', 'age.5.9', 'age.10.14', 
                      'age.15.19',
                      'age.20.24', 'age.25.29', 'age.30.34', 'age.35.39', 'age.40.44', 
                      'age.45.49', 'age.50.54', 'age.55.59', 'age.60.64', 'age.65.69',
                      'age.70.74', 'age.75.79', 'age.80.84', 'age.more85')
colnames(pop.2014)<-c('FIPS', 'County', 'total.pop', 'age.0.4', 'age.5.9', 'age.10.14', 
                  'age.15.19',
                  'age.20.24', 'age.25.29', 'age.30.34', 'age.35.39', 'age.40.44', 
                  'age.45.49', 'age.50.54', 'age.55.59', 'age.60.64', 'age.65.69',
                  'age.70.74', 'age.75.79', 'age.80.84', 'age.more85')

# Read in CDC Infant Population Data to split the 0-4 age group into infants and non-infants
mort.2011<-read.csv('Compressed Mortality 2011.txt', sep = '\t', 
                    stringsAsFactors = F)[c(3, 7)]
mort.2014<-read.csv('Compressed Mortality 2014.txt', sep = '\t', 
               stringsAsFactors = F)[c(3, 7)]

mort.2011$Population<-as.integer(mort.2011$Population)
mort.2014$Population<-as.integer(mort.2014$Population)
colnames(mort.2011)<-c('FIPS', 'age.less1')
colnames(mort.2014)<-c('FIPS', 'age.less1')
pop.2011<-left_join(pop.2011, mort.2011, by='FIPS')
pop.2014<-left_join(pop.2014, mort.2014, by='FIPS')

# Create column for 1-4 year olds
pop.2011$age.1.4<-NA
pop.2014$age.1.4<-NA

# Impute the infant population; use CDC data where available, 
# otherwise divide 0-4 age group by 5

# 2011
for(i in 1:nrow(pop.2011)){
  if(!is.na(pop.2011$age.less1[i])){
    pop.2011$age.less1[i]<-pop.2011$age.less1[i]}
  else{pop.2011$age.less1[i]<-pop.2011$age.0.4[i]/5}
  pop.2011$age.1.4[i]<-pop.2011$age.0.4[i]-pop.2011$age.less1[i]
}

pop.2011<-pop.2011[,-which(names(pop.2011) %in% "age.0.4")]

pop.2011<-pop.2011[, c('FIPS', 'age.less1', 'age.1.4', 'age.5.9', 'age.10.14', 'age.15.19',
                       'age.20.24', 'age.25.29', 'age.30.34', 'age.35.39', 'age.40.44', 
                       'age.45.49', 'age.50.54', 'age.55.59', 'age.60.64', 'age.65.69',
                       'age.70.74', 'age.75.79', 'age.80.84', 'age.more85', 'total.pop')]

# 2014
for(i in 1:nrow(pop.2014)){
  if(!is.na(pop.2014$age.less1[i])){
    pop.2014$age.less1[i]<-pop.2014$age.less1[i]}
  else{pop.2014$age.less1[i]<-pop.2014$age.0.4[i]/5}
  pop.2014$age.1.4[i]<-pop.2014$age.0.4[i]-pop.2014$age.less1[i]
}

pop.2014<-pop.2014[,-which(names(pop.2014) %in% "age.0.4")]

pop.2014<-pop.2014[, c('FIPS', 'age.less1', 'age.1.4', 'age.5.9', 'age.10.14', 'age.15.19',
               'age.20.24', 'age.25.29', 'age.30.34', 'age.35.39', 'age.40.44', 
               'age.45.49', 'age.50.54', 'age.55.59', 'age.60.64', 'age.65.69',
               'age.70.74', 'age.75.79', 'age.80.84', 'age.more85', 'total.pop')]

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
pop.2011<-anti_join(pop.2011, non.cont)
pop.2014<-anti_join(pop.2014, non.cont)
rm(non.cont, AK, AS, HI, PR, VI, rest)


# Assign Miami-Dade to its former FIPS # 12025
pop.2011$FIPS[which(pop.2011$FIPS==12086)]<-12025
pop.2014$FIPS[which(pop.2014$FIPS==12086)]<-12025

# Assign Oglala Lake County to its former FIPS #46113
pop.2011$FIPS[which(pop.2011$FIPS==46102)]<-46113
pop.2014$FIPS[which(pop.2014$FIPS==46102)]<-46113

# Assign all 8014 values to 8013 (8014 didn't exist when AP3 matrices were created)
pop.2011$FIPS[which(pop.2011$FIPS==8014)]<-8013
pop.2014$FIPS[which(pop.2014$FIPS==8014)]<-8013

# Summing up to add previous 8014 to 8013
#pop.2011<-pop.2011 %>% group_by(FIPS) %>% summarize_all(funs(sum)) 
pop.2011<-pop.2011 %>% group_by(FIPS) %>% summarize_all(list(sum))
#pop.2014<-pop.2014 %>% group_by(FIPS) %>% summarize_all(funs(sum)) 
pop.2014<-pop.2014 %>% group_by(FIPS) %>% summarize_all(list(sum))

# Add in empty rows for Bedford City and Clifton Forge City, VA
row1<-c(51515, rep(0, 20))
row2<-c(51560, rep(0, 20))
a<-data.frame(rbind(row1, row2))
names(a)<-names(pop.2014)
pop.2011<-rbind(a, pop.2011)
pop.2014<-rbind(a, pop.2014)
rm(row1, row2, a)

# Sort by FIPS
pop.2011<-pop.2011[order(pop.2011$FIPS),]
pop.2014<-pop.2014[order(pop.2014$FIPS),]


# Method for 2008 (take intercensal population totals and then divide them with the same key
# as the 2011 populations)
pop.2008.key<-pop.2011[, 1:20]
pop.2008.key[, 2:20]<-NA

for (i in 1:nrow(pop.2008.key)){
  for(j in 2:20){
    pop.2008.key[i, j]<-pop.2011[i, j]/pop.2011[i, 21]
  }
}

# Read in Intercensal population totals
intercensal.totals<-read.csv('intercensal_totals.csv')[, c('STATE', 'COUNTY', 'POPESTIMATE2008')]
intercensal.totals<-intercensal.totals %>% mutate(FIPS=STATE*1000+COUNTY)
intercensal.totals<-intercensal.totals[, c('FIPS', 'POPESTIMATE2008')]

# Assign Miami-Dade to its former FIPS # 12025
intercensal.totals$FIPS[which(intercensal.totals$FIPS==12086)]<-12025

# Assign all 8014 values to 8013 (8014 didn't exist when AP3 matrices were created)
intercensal.totals$FIPS[which(intercensal.totals$FIPS==8014)]<-8013

# Add population from FIPS #51515 to #51019 (Clifton City was 
# added to that county after 2010)
intercensal.totals$FIPS[which(intercensal.totals$FIPS==51515)]<-51019

# Summing up to add previous 8014 to 8013 and 51515 to 51019
#intercensal.totals<-intercensal.totals %>% group_by(FIPS) %>% summarize_all(funs(sum)) 
intercensal.totals<-intercensal.totals %>% group_by(FIPS) %>% summarize_all(list(sum)) 


intercensal.totals$FIPS<-as.numeric(intercensal.totals$FIPS)
pop.2008.key<-left_join(pop.2008.key, intercensal.totals)
pop.2008.key[is.na(pop.2008.key)]<-0

# Generate matrix for 2008, compute values based on key
pop.2008<-pop.2011[, 1:20]
pop.2008[, 2:20]<-NA

for (i in 1:nrow(pop.2008)){
  for(j in 2:20){
    pop.2008[i, j]<-pop.2008.key[i, 21]*pop.2008.key[i, j]
  }
}

write.table(pop.2008[,2:20], sep=",", 'pop_2008.csv',  col.names=FALSE, row.names=F)
write.table(pop.2011[,2:20], sep=",", 'pop_2011.csv',  col.names=FALSE, row.names=F)
write.table(pop.2014[,2:20], sep=",", 'pop_2014.csv',  col.names=FALSE, row.names=F)