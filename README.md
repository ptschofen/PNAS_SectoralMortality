# PNAS_SectoralMortality
## General Overview of script sequence

1. Calculate Effective Heights for facilities based on most recent available facility data
2. Pre-process NEI data for running AP3 model and future use in GED calculations, doing so separately for area sources and point sources
3. Run AP3 for marginal damage computations in Matlab
4. Run R scripts related to GED calculations
5. Post-processing of results in either R, Excel or ArcGIS


## Folder Paths for Code
Raw Data can be obtained from a CMU Box folder or requested via email. The folder path for reading in data is marked with "...PNAS_SectoralMortality"

To change folder paths search for "#__#" in R scripts and "%__%" in Matlab
Intermediate files generated are stored in "...Desktop/PNAS_SectoralMortality"

## Effective Heights Calculations
The effective heights are calculated via a Smoke file from EPA. We assume that all emissions from a facility are emitted through the highest available smokestack on file, and that effective heights for facilities with not enough data available are low enough to fall into the "Low Stack" category in AP3 and the category of area sources in EASIUR.

## Area Source NEI Processing
This is a fairly convoluted script (sorry). It requires the manual change of the NEI year in marked locations, and also a column name for the column pulling in the pollutant name changed from 2011 to 2014.

In Section 3 of the R script, biogenic VOC emissions get pulled out for the purpose of creating an input file for the AP3 model in Matlab (their calibration is different than for anthropogenic VOC emissions).

## Facility Data NEI Processing
2014 contains a mislabeled plant, and the FIPS code for the Four Corners plant was incorrectly stated, once.

Also, there are a number of facilities with no clear FIPS code attribution. For the purposes of having an input file for AP3, it was assumed that their emissions happen within the counties in the state in which they occur according to the fraction of NOx emissions from low stacks, however they were not further used for the computation of GED.

## Population/Mortality Data
Call up PM_Setup and configure input files (2011 worksheets, emissions, population, mortality), configure parameters for VRMR and DR, configure parameters for calibration from .pdf file
Call up Emission_comparisons

## How to use AP3
