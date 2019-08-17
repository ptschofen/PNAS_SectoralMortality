# PNAS_SectoralMortality
## General Overview of script sequence

1. Calculate Effective Heights for facilities based on most recent available facility data
2. Pre-process NEI data for running AP3 model and future use in GED calculations, doing so separately for area sources and point sources
3. Run AP3 for marginal damage computations in Matlab
4. Run R scripts related to GED calculations
5. Post-processing of results in either R, Excel or ArcGIS


## Folder Paths for Code
Raw Data can be obtained from a CMU Box folder or requested via email.

To change folder paths search for "#__#" in R scripts and "%__%" in Matlab
Intermediate files generated are stored in 'Desktop/PNAS_SectoralMortality'

## Effective Heights Calculations
The effective heights are calculated via a Smoke file from EPA. We assume that all emissions from a facility are emitted through the highest available smokestack on file, and that effective heights for facilities with not enough data available are low enough to fall into the "Low Stack" category in AP3 and the category of area sources in EASIUR.

## Area Source NEI Processing
This is a fairly convoluted script (sorry). It requires the manual change of the NEI year in marked locations, and also a column name for the column pulling in the pollutant name changed from 2011 to 2014.

In Section 3 of the R script, biogenic VOC emissions get pulled out for the purpose of creating an input file for the AP3 model in Matlab (their calibration is different than for anthropogenic VOC emissions).

## Facility Data NEI Processing
This file is also using manual changes for the years, because in the 2014 NEI there is a mislabeled plant.

Also, there are a number of facilities with no clear FIPS code attribution. For the purposes of having an input file for AP3, it was assumed that their emissions spread across the state in which they occur according to the fraction of NOx emissions from low stacks, however they were not further used for the computation of GED.
