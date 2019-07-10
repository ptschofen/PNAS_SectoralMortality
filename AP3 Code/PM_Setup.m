%% (* ::Package:: *)
clear all

%% Change this for 2008 or 2011 - for 2014 all relevant inputs are further down the script
load 'C:\Users\ptsch\Desktop\AP2 Data\2008_PM_Worksheet_Area_Low_Western_Adj'
load 'C:\Users\ptsch\Desktop\AP2 Data\2008_PM_Worksheet_Med_Tall_Western_Adj'

%% Change Emission to my own generated files
Area_Source{4,1}=csvread('area_sources_2008.csv'); 
Low_Stack{4,1}=csvread('low_2008.csv'); 
Med_Stack{4,1}=csvread('medium_2008.csv'); 
Tall_Stack{4,1}=csvread('tall_2008.csv');
New_Tall{4,1}=csvread('tall2_2008.csv');

%% Change Population for 2014 and Mortality for all years
%Mortality{6,1}=csvread('pop_2014.csv');
Mortality{3,1}=csvread('mort_2008.csv');

%% Set Calibration Parameters
NH4_Cal=0.3;
NOx_Cal=0.52;
PM25_Cal=.58;
SO2_Cal=1.1;
VOC_Cal=.03;
B_VOC_Cal=.032;

%% Reminder: Also change csv files to write in Emission_comparisons.m file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SO2 = zeros (3109,5);
NOx = zeros (3109,5);
NO3 = zeros (3109,1);
PM_25_Primary = zeros (3109,5);
NH3 = zeros (3109,5);
NH4 = zeros (3109,1);
NH4e = zeros (3109,1);
SO4 = zeros (3109,1);
A_VOC = zeros (3109,5);
B_VOC = zeros (3109,1);

PM_25_A = zeros (3109,1);
PM_25_Dust = zeros(3109,1);
PM_25_L = zeros (3109,1);
PM_25_M = zeros (3109,1);
PM_25_T = zeros (565,1);
PM_25_T2 = zeros (91,1);
NOx_A = zeros (3109,1);
NOx_L = zeros (3109,1);
NOx_M = zeros (3109,1);
NOx_T = zeros (565,1);
NOx_T2 = zeros (91,1);
SO2_A = zeros (3109,1);
SO2_L = zeros (3109,1);
SO2_M = zeros (3109,1);
SO2_T = zeros (565,1);
SO2_T2 = zeros (91,1);
NH3_A = zeros (3109,1);
NH3_L = zeros (3109,1);
NH3_M = zeros (3109,1);
NH3_T = zeros (565,1);
NH3_T2 = zeros (91,1);
VOC_A = zeros (3109,1);
VOC_L = zeros (3109,1);
VOC_M = zeros (3109,1);
VOC_T = zeros (565,1);
VOC_T2 = zeros (91,1);
PM_25_B = zeros (3109,1);

All_Mort = cell(4,1);

%% Non-Dust Portion PM_Primary
%Area_Source{4,1}(:,9) = Area_Source{4,1}(:,4)- (Area_Source{4,1}(:,8));

%% WILLINGNESS TO PAY

%Mortality
% Mrozek, Taylor: $1,963,840 (2000)
% EPA: $ 5,907,840 (2000); $ 4,800,000 ($1990)
% EPA: $ 7,520,000 (2030)
% EPA: $ 6,313,041 (2005)
% EPA: $ 7,400,000 ($2006 currently on the website)
% EPA: $ 6,299,143 ($2000)

WTP_Mort = 6299143;

%Morbidity
% 320000 USEPA (812 First Prospective)
% 398612 USEPA BenMAP $2006
% WTP_Morb = 320000;

%% Number of Sources
S = 3109;
T = 565;
T2 = 91;

%% Select Damage Endpoints
Model_Morbidity = 0;
