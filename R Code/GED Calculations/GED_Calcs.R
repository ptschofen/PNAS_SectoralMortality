setwd('C:/Users/ptsch/Desktop/PNAS_SectoralMortality')

## Load Packages, set working directory
library(dplyr)
library(tidyr)
library(foreign)
library(readstata13)

## Some useful groups
mds<-c('MD.NH3', 'MD.NOx', 'MD.PM25', 'MD.SO2', 'MD.VOC')
emi<-c('NH3', 'NOx', 'PM25', 'SO2', 'VOC')
ged<-c('GED.NH3', 'GED.NOx', 'GED.PM25', 'GED.SO2', 'GED.VOC')

year<-c('2008', '2011', '2014')
# Numbers for this computed with per capita GDP data downloaded from St. Louis FED (FRED)
inc.adj<-c(0.999312286, 0.995604867, 1.013200986)

## Read in FIPS list for correct order
FIPS<-read.csv('fips_apeep.csv')
names(FIPS)[3]<-"FIPS"
FIPS<-FIPS[3]

## Read in NAICS Mapping file
naics.map<-read.csv('naics_map.csv')
for(k in 1:3){
  print(k)
## Read in AP3 Tall and Tall 2 data, remove unneeded columns
tall<-read.dta13("Tall1_List_AP2.dta")
tall<-tall[, c('eis', 'fips')]
names(tall)<-c('eis', 'FIPS')
tall2<-read.dta13("Tall2_List_AP2_Update.dta")
tall2<-tall2[, c('eisidentifier', 'fips2')]
names(tall2)<-c("eis", 'FIPS')
tall2$FIPS<-as.integer(tall2$FIPS)
  
## Read in facilities file and mobile file
facilities<-read.csv(paste(year[k], '_facilities.csv', sep=''))
facilities<-facilities[, c('eis', 'NAICS', 'FIPS', emi)]

## Read in effective heights, join with facilities, 
## add in tall and tall2, classify NAs as low or Area
eff.heights<-read.csv('eff_heights_2014.csv')
eff.heights<-subset(eff.heights, select=-FIPS)

tall<-tall%>% group_by(eis) %>% summarize()
tall2<-tall2 %>% group_by(eis) %>% summarize()

# Remove duplicates from Tall 2 (they are contained in Tall)
tall2<-tall2[!tall2$eis==717611,]
tall2<-tall2[!tall2$eis==8183111,]
tall2<-tall2[!tall2$eis==7335511,]
tall2<-tall2[!tall2$eis==6815611,]

tall$eff_height<-999
tall$ap3.assignment<-'Tall'
tall$easiur.assignment<-'Tall 300'

tall2$eff_height<-999
tall2$ap3.assignment<-'Tall2'
tall2$easiur.assignment<-'Tall 300'

# make sure no tall or tall2 are in the eff.heights file
eff.heights<-anti_join(eff.heights, tall, by='eis')
eff.heights<-anti_join(eff.heights, tall2, by='eis')

eff.heights<-rbind(eff.heights, tall)
eff.heights<-rbind(eff.heights, tall2)

eff.heights<-left_join(facilities[,1:3], eff.heights)

eff.heights$ap3.assignment[which(is.na(eff.heights$ap3.assignment))]<-'Low'
eff.heights$easiur.assignment[which(is.na(eff.heights$easiur.assignment))]<-'Area'

# Join AP3 Assignment and Easiur Assignment to facilities
facilities<-left_join(facilities, eff.heights[, c(1, 5, 6)], by='eis')

facilities<-facilities[, c('eis', 'NAICS', 'FIPS', 
                           'ap3.assignment', 'easiur.assignment', emi)]

###### AP3 Method
fac.low<-eff.heights[which(eff.heights$ap3.assignment=='Low'),]
fac.med<-eff.heights[which(eff.heights$ap3.assignment=='Medium'),]
fac.tall<-eff.heights[which(eff.heights$ap3.assignment=='Tall'),]
fac.tall2<-eff.heights[which(eff.heights$ap3.assignment=='Tall2'),]

## Read in MD files, FIPS codes
MD.A<-read.csv((paste('md_A_', year[k], '.csv', sep='')), header = F)
colnames(MD.A)<-mds
MD.A<-cbind(FIPS, MD.A)
MD.L<-read.csv((paste('md_L_', year[k], '.csv', sep='')), header = F)
colnames(MD.L)<-mds
MD.L<-cbind(FIPS, MD.L)
MD.M<-read.csv((paste('md_M_', year[k], '.csv', sep='')), header = F)
colnames(MD.M)<-mds
MD.M<-cbind(FIPS, MD.M)
MD.T<-read.csv((paste('md_T_', year[k], '.csv', sep='')), header = F)
colnames(MD.T)<-mds
MD.T2<-read.csv((paste('md_T2_', year[k], '.csv', sep='')), header = F)
colnames(MD.T2)<-mds

## Read in AP3's Tall and Tall 2 data, remove unneeded columns
tall<-read.dta13("Tall1_List_AP2.dta")
tall<-tall[, c('eis', 'fips')]
names(tall)<-c('eis', 'FIPS')
tall2<-read.dta13("Tall2_List_AP2_Update.dta")
tall2<-tall2[, c('eisidentifier', 'fips2')]
names(tall2)<-c("eis", 'FIPS')
tall2$FIPS<-as.integer(tall2$FIPS)

# Group by EIS
MD.T<-cbind(tall, MD.T)
MD.T<- MD.T %>% group_by(eis) %>% summarize(MD.NH3=first(MD.NH3),
                                            MD.NOx=first(MD.NOx),
                                            MD.PM25=first(MD.PM25),
                                            MD.SO2=first(MD.SO2),
                                            MD.VOC=first(MD.VOC))

MD.T2<-cbind(tall2, MD.T2)
MD.T2<- MD.T2 %>% group_by(eis) %>% summarize(MD.NH3=first(MD.NH3),
                                              MD.NOx=first(MD.NOx),
                                              MD.PM25=first(MD.PM25),
                                              MD.SO2=first(MD.SO2),
                                              MD.VOC=first(MD.VOC))

## Link marginal damages to the respective facilities
fac.low<-left_join(fac.low, MD.L, by='FIPS')
fac.med<-left_join(fac.med, MD.M, by='FIPS')
fac.tall<-left_join(fac.tall, MD.T, by='eis')
fac.tall2<-left_join(fac.tall2, MD.T2, by='eis')

facilities.MD<-rbind(fac.low, fac.med, fac.tall, fac.tall2)
facilities.MD<-facilities.MD[,-which(names(facilities.MD) %in% 'eff_height')]
facilities.MD[is.na(facilities.MD)]<-0

facilities<-facilities[order(facilities$eis),]
facilities.MD<-facilities.MD[order(facilities.MD$eis),]
facilities.GED<-facilities[, emi]*facilities.MD[, mds]
names(facilities.GED)<-ged

facilities.GED <- facilities.GED %>% mutate(GED.sum=GED.NH3+GED.NOx+GED.PM25+GED.SO2+GED.VOC)

joint.total<-cbind(facilities, facilities.GED)

## Group by NAICS
joint.by.naics<-joint.total %>% group_by(NAICS) %>% 
  summarize(E.NH3=sum(NH3, na.rm=T),
            E.NOx=sum(NOx, na.rm=T),
            E.PM25=sum(PM25, na.rm=T),
            E.SO2=sum(SO2, na.rm=T),
            E.VOC=sum(VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T),
            GED.NOx=sum(GED.NOx, na.rm=T),
            GED.PM25=sum(GED.PM25, na.rm=T),
            GED.SO2=sum(GED.SO2, na.rm=T),
            GED.VOC=sum(GED.VOC, na.rm=T),
            GED.sum=sum(GED.sum, na.rm=T))

## Join NAICS Dictionary to this
joint.all.naics<-left_join(joint.by.naics, naics.map, by='NAICS')

## Read in Area sources
area.sources.total<-read.csv(paste('area_sources_for_NAICS_', year[k], '.csv', sep=''))
names(area.sources.total)<-c('SCC', 'FIPS', 'County', 'Description', emi)

# SCC to NAICS mapping was done in Excel, the file read in is the mapping
scc.list<-read.csv('scc_list_updated.csv')

scc.list<-scc.list[c('SCC', 'naics.sector', 'naics.subsector',
                     'naics.summary', 'naics.industry')]

## Join SCC/Naics file to area sources
scc.list[,1]<-as.numeric(as.character(scc.list[,1]))

area.sources.naics<-left_join(area.sources.total, scc.list, by='SCC')

## Group by FIPS and NAICS
area.sources.grouped<- area.sources.naics %>% 
  group_by_at(vars(FIPS, naics.sector, naics.subsector, naics.summary, naics.industry)) %>% 
  summarize(NH3=sum(NH3, na.rm=T),
            NOx=sum(NOx, na.rm=T),
            PM25=sum(PM25, na.rm=T),
            SO2=sum(SO2, na.rm=T),
            VOC=sum(VOC, na.rm=T))

# Join Emissions and MDs
joint.A<-left_join(area.sources.grouped, MD.A, by='FIPS')

GED.A<-joint.A[, emi]*joint.A[, mds]
colnames(GED.A)<-ged
GED.A$GED.sum<-GED.A$GED.NH3 + GED.A$GED.NOx + GED.A$GED.PM25 + 
  GED.A$GED.SO2 + GED.A$GED.VOC

# For some reason this only works if a file is generated and reloaded
write.csv(joint.A, 'j.csv', row.names = F)
joint.A<-read.csv('j.csv')

joint.A<-cbind(joint.A, GED.A)
names(joint.A)[2:5]<-c('sector', 'subsector', 'summary', 'industry')

## Sum by sector and adjust for VRMR income elasticity
naics.sector.fac<-joint.all.naics %>% group_by(sector) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

naics.sector.as<-joint.A %>% group_by(sector) %>%  
  summarize(E.NH3=sum(NH3, na.rm=T),
            E.NOx=sum(NOx, na.rm=T),
            E.PM25=sum(PM25, na.rm=T),
            E.SO2=sum(SO2, na.rm=T),
            E.VOC=sum(VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

## Sum by subsector and inflate to 2012 prices
naics.subsector.fac<-joint.all.naics %>% group_by(subsector) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

naics.subsector.as<-joint.A %>% group_by(subsector) %>%  
  summarize(E.NH3=sum(NH3, na.rm=T),
            E.NOx=sum(NOx, na.rm=T),
            E.PM25=sum(PM25, na.rm=T),
            E.SO2=sum(SO2, na.rm=T),
            E.VOC=sum(VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

## Sum by industry group and inflate to 2012 prices
naics.summary.fac<-joint.all.naics %>% group_by(summary) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

naics.summary.as<-joint.A %>% group_by(summary) %>%  
  summarize(E.NH3=sum(NH3, na.rm=T),
            E.NOx=sum(NOx, na.rm=T),
            E.PM25=sum(PM25, na.rm=T),
            E.SO2=sum(SO2, na.rm=T),
            E.VOC=sum(VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

naics.sector.total<-rbind(naics.sector.fac, naics.sector.as)
naics.subsector.total<-rbind(naics.subsector.fac, naics.subsector.as)
naics.summary.total<-rbind(naics.summary.fac, naics.summary.as)

naics.sector.total<-naics.sector.total %>% group_by(sector) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
             E.NOx=sum(E.NOx, na.rm=T),
             E.PM25=sum(E.PM25, na.rm=T),
             E.SO2=sum(E.SO2, na.rm=T),
             E.VOC=sum(E.VOC, na.rm=T),
             GED.NH3=sum(GED.NH3, na.rm=T),
             GED.NOx=sum(GED.NOx, na.rm=T),
             GED.PM25=sum(GED.PM25, na.rm=T),
             GED.SO2=sum(GED.SO2, na.rm=T),
             GED.VOC=sum(GED.VOC, na.rm=T),
             GED.sum=sum(GED.sum, na.rm=T))

sector.order<-read.csv('sector_order.csv', header = F)
names(sector.order)<-'sector'
naics.sector.total<-left_join(sector.order, naics.sector.total)

naics.subsector.total<-naics.subsector.total %>% group_by(subsector) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T),
            GED.NOx=sum(GED.NOx, na.rm=T),
            GED.PM25=sum(GED.PM25, na.rm=T),
            GED.SO2=sum(GED.SO2, na.rm=T),
            GED.VOC=sum(GED.VOC, na.rm=T),
            GED.sum=sum(GED.sum, na.rm=T))

naics.subsector.total<-naics.subsector.total[!is.na(naics.subsector.total$subsector),]

naics.summary.total<-naics.summary.total %>% group_by(summary) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T),
            GED.NOx=sum(GED.NOx, na.rm=T),
            GED.PM25=sum(GED.PM25, na.rm=T),
            GED.SO2=sum(GED.SO2, na.rm=T),
            GED.VOC=sum(GED.VOC, na.rm=T),
            GED.sum=sum(GED.sum, na.rm=T))

naics.summary.total<-naics.summary.total[!is.na(naics.summary.total$summary),]

write.csv(naics.sector.total, paste('naics_sector_', year[k], '.csv', sep=''),
          row.names = F)
write.csv(naics.subsector.total, paste('naics_subsector_',
                                       year[k], '.csv', sep=''), row.names = F)
write.csv(naics.summary.total, paste('naics_summary_',
                                       year[k], '.csv', sep=''), row.names = F)

## Read in Value added file (original file:
## https://apps.bea.gov/iTable/index_industry_gdpIndy.cfm
## Underlying tables -> Real Value added by industry

value.added<-read.csv('VA_for_ModelYears.csv')
naics.sector<-read.csv(paste('naics_sector_', year[k], '.csv', sep=''))
naics.subsector<-read.csv(paste('naics_subsector_', year[k], '.csv', sep=''))
naics.summary<-read.csv(paste('naics_summary_', year[k], '.csv', sep=''))

value.added<-value.added[, c('Sector', noquote(paste('VA.', year[k], sep='')))]
names(value.added)<-c('sector', 'VA')

### Sectoral Analysis
naics.sector$sector<-as.character(naics.sector$sector)
value.added$sector<-as.character(value.added$sector)
va.sector<-left_join(naics.sector, value.added, by='sector')

## Convert everything to $  billion and inflate VA data
va.sector$GED.sum<-va.sector$GED.sum/10^9
va.sector$VA<-va.sector$VA/10^3*1.09996

## calculate GED/VA ratios
va.sector$GED.VA<-va.sector$GED.sum/va.sector$VA

### Subsector Analysis
names(value.added)<-c('subsector', 'VA')

### Subsectoral Analysis
naics.subsector$subsector<-as.character(naics.subsector$subsector)
value.added$subsector<-as.character(value.added$subsector)
va.subsector<-left_join(naics.subsector, value.added, by='subsector')

## Convert everything to $billion
va.subsector$GED.sum<-va.subsector$GED.sum/10^9
va.subsector$VA<-va.subsector$VA/10^3*1.09996

## calculate GED/VA ratios
va.subsector$GED.VA<-va.subsector$GED.sum/va.subsector$VA

### Industry Grp
names(value.added)<-c('summary', 'VA')

### Industry Group Analysis
naics.summary$summary<-as.character(naics.summary$summary)
value.added$summary<-as.character(value.added$summary)
va.summary<-left_join(naics.summary, value.added, by='summary')

## Convert everything to $billion
va.summary$GED.sum<-va.summary$GED.sum/10^9
va.summary$VA<-va.summary$VA/10^3*1.09996

## calculate GED/VA ratios
va.summary$GED.VA<-va.summary$GED.sum/va.summary$VA

## Create tables
TA1<-va.sector[, c(1, 12, 14)] # Used for table 1 and in full form in SI appendix
TA2<-va.subsector[, c(1, 12)] # used for Fig. 3
T1<-va.summary[, c(1, 14)] # Used for Table 1
# Remove private households
T1<-T1[-which(T1$summary=='Private households'),]
T1<-T1[order(T1$GED.VA, decreasing = T), ]
T1<-T1[1:10, ]

write.csv(TA1, paste('sector_overview_', year[k], '.csv', sep=''), row.names = F)
write.csv(TA2, paste('subsectors_descending_', year[k], '.csv', sep=''), row.names = F)
write.csv(T1, paste('top_10_summary_ged_va_', year[k], '.csv', sep=''), row.names = F)

assign(paste("va.sector", year[k], sep = ".") , va.sector)
assign(paste("va.subsector", year[k], sep = ".") , va.subsector)
assign(paste("va.summary", year[k], sep = ".") , va.summary)
assign(paste("fac.ged", year[k], sep = ".") , joint.total)
assign(paste("area.ged", year[k], sep = ".") , joint.A)
assign(paste("T1", year[k], sep = ".") , TA1)
assign(paste("T2", year[k], sep = ".") , TA2)

## EASIUR method (remove pollutants in MD file that will be replaced by EASIUR MDs)
facilities.MD<-facilities.MD[-which(names(facilities.MD) %in% c('MD.NH3', 'MD.NOx', 
                                                                'MD.PM25', 'MD.SO2'))]

# Read in data, select columns of interest
easiur.mds<-read.csv('EASIUR MDs.csv')
easiur.mds<-easiur.mds[which(names(easiur.mds) %in% c('FIPS', 'PEC.Annual.Area',
                                                      'PEC.Annual.P150', 'PEC.Annual.P300',
                                                      'SO2.Annual.Area', 
                                                      'SO2.Annual.P150',
                                                      'SO2.Annual.P300', 'NOX.Annual.Area', 
                                                      'NOX.Annual.P150', 'NOX.Annual.P300',
                                                      'NH3.Annual.Area', 'NH3.Annual.P150', 
                                                      'NH3.Annual.P300'))]

pop.adj<-read.csv('EASIUR_MD_Population_adjust.csv')
pop.adj<-pop.adj[which(names(pop.adj) %in% c('FIPS', 'PEC.Annual.Area',
                                                      'PEC.Annual.P150', 'PEC.Annual.P300',
                                                      'SO2.Annual.Area', 
                                                      'SO2.Annual.P150',
                                                      'SO2.Annual.P300', 'NOX.Annual.Area', 
                                                      'NOX.Annual.P150', 'NOX.Annual.P300',
                                                      'NH3.Annual.Area', 'NH3.Annual.P150', 
                                                      'NH3.Annual.P300'))]

# Adjust for population and mortality change according to EASIUR method suggested in SI
easiur.mds[, 2:13]<-easiur.mds[, 2:13]*pop.adj[, 2:13]^(as.numeric(noquote(year[k]))-2005)

# Convert to short tons ($/tonne)*(tonne/1.10231 short tons)
easiur.mds[, 2:13]<-easiur.mds[, 2:13]/1.10231

# Adjust for different VSL Used (Easiur: $8.8M in $2010, This paper: $8.1M in $2010)
easiur.mds[, 2:13]<-easiur.mds[, 2:13]/1.0911

# Change FIPS code of Miami Dade to APEEP format
easiur.mds$FIPS[which(easiur.mds$FIPS==12086)]<-12025

# Reorder by FIPS
easiur.mds<-easiur.mds[order(easiur.mds$FIPS),]

easiur.mds.area<-easiur.mds[which(names(easiur.mds) %in% c('FIPS','NH3.Annual.Area', 
                                                           'NOX.Annual.Area', 
                                                           'PEC.Annual.Area', 'SO2.Annual.Area'))]
easiur.mds.area$easiur.assignment<-'Area'
easiur.mds.area<-easiur.mds.area[, c('FIPS', 'NH3.Annual.Area', 'NOX.Annual.Area', 'PEC.Annual.Area', 'SO2.Annual.Area', 'easiur.assignment')]
names(easiur.mds.area)<-c('FIPS', 'MD.NH3', 'MD.NOx', 'MD.PM25', 'MD.SO2', 'easiur.assignment')

easiur.mds.med150<-easiur.mds[which(names(easiur.mds) %in% c('FIPS','NH3.Annual.P150', 
                                                             'NOX.Annual.P150', 
                                                             'PEC.Annual.P150', 
                                                             'SO2.Annual.P150'))]
easiur.mds.med150$easiur.assignment<-'Med 150'
easiur.mds.med150<-easiur.mds.med150[, c('FIPS', 'NH3.Annual.P150', 'NOX.Annual.P150', 'PEC.Annual.P150', 'SO2.Annual.P150', 'easiur.assignment')]
names(easiur.mds.med150)<-c('FIPS', 'MD.NH3', 'MD.NOx', 'MD.PM25', 'MD.SO2', 'easiur.assignment')
easiur.mds.tall300<-easiur.mds[which(names(easiur.mds) %in% c('FIPS','NH3.Annual.P300', 
                                                              'NOX.Annual.P300', 
                                                              'PEC.Annual.P300', 
                                                              'SO2.Annual.P300'))]

easiur.mds.tall300$easiur.assignment<-'Tall 300'
easiur.mds.tall300<-easiur.mds.tall300[, c('FIPS', 'NH3.Annual.P300', 'NOX.Annual.P300', 'PEC.Annual.P300', 'SO2.Annual.P300', 'easiur.assignment')]
names(easiur.mds.tall300)<-c('FIPS', 'MD.NH3', 'MD.NOx', 'MD.PM25', 'MD.SO2', 'easiur.assignment')
easiur.mds.combined<-rbind(easiur.mds.area, easiur.mds.med150, easiur.mds.tall300)

# Inflate to from 2010 to 2018
easiur.mds.combined[, 2:5]<-easiur.mds.combined[, 2:5]*1.155948
easiur.mds.combined$easiur.assignment<-as.factor(easiur.mds.combined$easiur.assignment)
rm(easiur.mds, pop.adj, easiur.mds.med150, easiur.mds.tall300)

facilities.MD<-left_join(facilities.MD, easiur.mds.combined, by=c('FIPS', 'easiur.assignment'))
facilities.MD<-facilities.MD[, c('eis', 'NAICS', 'FIPS', 'ap3.assignment', 
                                 'easiur.assignment', mds)]

facilities.GED<-facilities[, emi]*facilities.MD[, mds]
names(facilities.GED)<-ged

facilities.GED <- facilities.GED %>% mutate(GED.sum=GED.NH3+GED.NOx+GED.PM25+GED.SO2+GED.VOC)

joint.total.easiur<-cbind(facilities, facilities.GED)

## Group by NAICS
joint.by.naics.easiur<-joint.total.easiur %>% group_by(NAICS) %>% 
  summarize(E.NH3=sum(NH3, na.rm=T),
            E.NOx=sum(NOx, na.rm=T),
            E.PM25=sum(PM25, na.rm=T),
            E.SO2=sum(SO2, na.rm=T),
            E.VOC=sum(VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T),
            GED.NOx=sum(GED.NOx, na.rm=T),
            GED.PM25=sum(GED.PM25, na.rm=T),
            GED.SO2=sum(GED.SO2, na.rm=T),
            GED.VOC=sum(GED.VOC, na.rm=T),
            GED.sum=sum(GED.sum, na.rm=T))

## Join NAICS Dictionary to this
joint.all.naics.easiur<-left_join(joint.by.naics.easiur, naics.map, by='NAICS')

## Use AP3 MDs for VOC emissions
MD.A.easiur<-MD.A[, c(1, 6)]
MD.A.easiur<-left_join(MD.A.easiur, easiur.mds.area, by='FIPS')
MD.A.easiur<-MD.A.easiur[, c('FIPS', mds)]

# Join Emissions and MDs
joint.A.easiur<-left_join(area.sources.grouped, MD.A.easiur, by='FIPS')

GED.A.easiur<-joint.A.easiur[, emi]*joint.A.easiur[, mds]
colnames(GED.A.easiur)<-ged
GED.A.easiur$GED.sum<-GED.A.easiur$GED.NH3 + GED.A.easiur$GED.NOx + GED.A.easiur$GED.PM25 + 
  GED.A.easiur$GED.SO2 + GED.A.easiur$GED.VOC

write.csv(joint.A.easiur, 'j.csv', row.names = F)
joint.A.easiur<-read.csv('j.csv')

joint.A.easiur<-cbind(joint.A.easiur, GED.A.easiur)
names(joint.A.easiur)[2:4]<-c('sector', 'subsector', 'industry')

## Sum by sector and inflate to 2012 prices
naics.sector.fac.easiur<-joint.all.naics.easiur %>% group_by(sector) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])

naics.sector.as.easiur<-joint.A.easiur %>% group_by(sector) %>%  
  summarize(E.NH3=sum(NH3, na.rm=T),
            E.NOx=sum(NOx, na.rm=T),
            E.PM25=sum(PM25, na.rm=T),
            E.SO2=sum(SO2, na.rm=T),
            E.VOC=sum(VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T)*inc.adj[k],
            GED.NOx=sum(GED.NOx, na.rm=T)*inc.adj[k],
            GED.PM25=sum(GED.PM25, na.rm=T)*inc.adj[k],
            GED.SO2=sum(GED.SO2, na.rm=T)*inc.adj[k],
            GED.VOC=sum(GED.VOC, na.rm=T)*inc.adj[k],
            GED.sum=sum(GED.sum, na.rm=T)*inc.adj[k])


naics.sector.total.easiur<-rbind(naics.sector.fac.easiur, naics.sector.as.easiur)

naics.sector.total.easiur<-naics.sector.total.easiur %>% group_by(sector) %>%
  summarize(E.NH3=sum(E.NH3, na.rm=T),
            E.NOx=sum(E.NOx, na.rm=T),
            E.PM25=sum(E.PM25, na.rm=T),
            E.SO2=sum(E.SO2, na.rm=T),
            E.VOC=sum(E.VOC, na.rm=T),
            GED.NH3=sum(GED.NH3, na.rm=T),
            GED.NOx=sum(GED.NOx, na.rm=T),
            GED.PM25=sum(GED.PM25, na.rm=T),
            GED.SO2=sum(GED.SO2, na.rm=T),
            GED.VOC=sum(GED.VOC, na.rm=T),
            GED.sum=sum(GED.sum, na.rm=T))

sector.order<-read.csv('sector_order.csv', header = F)
names(sector.order)<-'sector'
naics.sector.total.easiur<-left_join(sector.order, naics.sector.total.easiur)

write.csv(naics.sector.total.easiur, paste('naics_sector_easiur_', year[k], '.csv', sep='')
          , row.names = F)

## Read in Value added file again
value.added<-read.csv('VA_for_ModelYears.csv')
naics.sector.easiur<-read.csv(paste('naics_sector_easiur_', year[k], '.csv', sep=''))

value.added<-value.added[,c(1,k+1)]
names(value.added)<-c('sector', 'VA')

### Sectoral Analysis
naics.sector.easiur$sector<-as.character(naics.sector.easiur$sector)
value.added$sector<-as.character(value.added$sector)
va.sector<-left_join(naics.sector.easiur, value.added, by='sector')

## Convert everything to $ billion and VA to 2018
va.sector$GED.sum<-va.sector$GED.sum/10^9
va.sector$VA<-va.sector$VA/10^3*1.09996

## calculate GED/VA ratios
va.sector$GED.VA<-va.sector$GED.sum/va.sector$VA

## Create tables for CEDM seminar
T1.easiur<-va.sector[, c(1, 12, 14)]
write.csv(T1.easiur, paste('easiur_sector_overview_', year[k], '.csv', sep=''), row.names = F)

assign(paste("easiur.va.sector", year[k], sep = ".") , va.sector)

rm(area.sources.grouped, area.sources.naics, area.sources.total, eff.heights)
rm(fac.low, fac.med, fac.tall, fac.tall2, facilities.GED, facilities.MD)
rm(GED.A, MD.A, MD.L, MD.M, MD.T, MD.T2, naics.sector, naics.subsector, naics.summary)
rm(naics.sector.as, naics.sector.total, naics.subsector.as, naics.subsector.fac)
rm(naics.subsector.total, tall, tall2, value.added, naics.summary.as, naics.summary.total)
rm(naics.summary.fac)
}