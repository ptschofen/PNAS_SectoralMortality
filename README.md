# PNAS_SectoralMortality
## General Overview of script sequence

1. Calculate Effective Heights for facilities based on most recent available facility data
2. Pre-process NEI data for running AP3 model and future use in GED calculations
3. Run AP3 for marginal damage computations in Matlab
4. Run R scripts related to GED calculations
5. Post-processing of results in either R, Excel or ArcGIS


## Folder Paths for Code
Large input files (such as raw datafiles from EPA NEI) are stored in a publicly available CMU Box folder (https://cmu.box.com/v/PNAS-SectoralMortality) or can be made available on request

Intermediate files generated are stored in 'Desktop/PNAS_SectoralMortality' 

## Effective Heights Calculations
The effective heights are calculated via a Smoke file from EPA. We assume that all emissions from a facility are emitted through the highest available smokestack on file, and that effective heights for facilities with not enough data available are low enough to fall into the "Low Stack" category in AP3 and the category of area sources in EASIUR.

