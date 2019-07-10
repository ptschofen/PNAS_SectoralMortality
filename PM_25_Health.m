% Pope, 1995 = 0.006408
% Pope, 2002 = 0.006
% Pope, 2002 = 0.005826891 (BENMAP)
% Krewski, 2000 = 0.007347
% Dockery, 1993 = 0.0124
% Laden, 2006 = 0.016
% Laden, 2006 = 0.014842001 (BENMAP)
% Roman, 2009 = 0.009355

% Mrozek, Taylor: $1,963,840 (2000)
% EPA: $ 5,907,840 (2000); $ 4,800,000 ($1990)
% EPA: $ 7,520,000 (2030)
% EPA: $ 6,313,041 (2005)

% Deaths = ((Mort2002.*((One'*((exp(0.006.*PM_25')))-1)'))).*Pop_over_30;

%% Log-linear Model
% Deaths = ((Mortality{3,1}.*((One'*((exp(0.006.*PM_25')))-1)'))).*Pop_over_30;

%% BenMAP Form
Deaths = (Mortality{3,1}.*(One'*(1-(1./(exp(0.005826891.*PM_25')))))').*Pop_over_30;
% Deaths = (MortalityRates2011FinalwithUnreliable.*(One'*(1-(1./(exp(0.005826891.*PM_25')))))').*Pop_over_30;
% Deaths = (MortalityRates2011FinalSpatial.*(One'*(1-(1./(exp(0.005826891.*PM_25')))))').*Pop_over_30;
DA = sum(sum(Deaths));

   %Cause-Specific Deaths
   
% Deaths_CP = (Mortality{9,1}.*(One'*(1-(1./(exp(0.0153.*PM_25')))))').*Pop_over_30;
% Deaths_CV = (Mortality{10,1}.*(One'*(1-(1./(exp(0.0206.*PM_25')))))').*Pop_over_30;
% Deaths_IHD = (Mortality{11,1}.*(One'*(1-(1./(exp(0.0306.*PM_25')))))').*Pop_over_30;
% 
% Mort_CP = sum(sum(Deaths_CP.*WTP_Mort));
% Mort_CV = sum(sum(Deaths_CV.*WTP_Mort));
% Mort_IHD = sum(sum(Deaths_IHD.*WTP_Mort));
%Mort_Adult_Spatial = Deaths.*WTP_Mort;
%Mort = sum(sum(Deaths.*WTP_Mort));

% USEPA VSLY
% Mort = sum(sum(Deaths.*VSLY_6M_CDC_2008_Update));

% Viscusi Aldy REEP
Mort = sum(sum(Deaths.*WTP_Mort));
% Mrozek, Taylor, 2002 VSLY
% Mort = sum(sum(Deaths.*Mortality{7,1}));
% run C:\APEEP_V_2005\Scripts_2005\PM\Cessation_Lag.m
% Infant = ((Mort2002.*((One'*((exp(0.007.*PM_25')))-1)'))).*Pop_Infant;

%% Log-linear Model
% Infant = ((Mort2002.*((One'*((exp(0.007.*PM_25')))-1)'))).*Pop_Infant;

%% BenMAP Form
Infant = (Mortality{3,1}.*(One'*(1-(1./(exp(0.006765865.*PM_25')))))').*Pop_Infant;
% Infant = (MortalityRates2011FinalwithUnreliable.*(One'*(1-(1./(exp(0.006765865.*PM_25')))))').*Pop_Infant;
% Infant = (MortalityRates2011FinalSpatial.*(One'*(1-(1./(exp(0.006765865.*PM_25')))))').*Pop_Infant;

% Mort_Infant = sum(sum(Infant.*VSLY_6M_CDC_2008_Update));
Mort_Infant = sum(sum(Infant.*WTP_Mort));
% Mort_Infant = sum(sum(Infant.*Mortality{7,1}));
%Mort_Infant_Spatial = Infant.*WTP_Mort;
% Klemm, Mason 2004 (HEI Updated)

% Deaths = ((Mortality{3,1}.*((One'*((exp(0.0008.*PM_25')))-1)').*Pop_over_30));
% Acute_Mort = sum(sum((Deaths).*Mortality{7,1}));
% Harvest = sum(sum(4500.*(0.2.*(Deaths))));

All_Mort{1,1} = (Mort+Mort_Infant);
%Spatial_Mort_Add = Mort_Adult_Spatial+Mort_Infant_Spatial;

    % Cause-Specific Totals
    
% All_Mort{2,1} = (Mort_CP+Mort_Infant);
% All_Mort{3,1} = (Mort_CV+Mort_Infant);
% All_Mort{4,1} = (Mort_IHD+Mort_Infant);

%% Chronic Bronchitis BenMAP Form
%% Abbey, et al. (1995)
% Cases_CB = 1-(1./((1-0.00378)*One'*(exp(0.013185041*PM_25')))+0.00378)'.*Pop_over_30.*0.00378.*(1-0.0476);
% Cases_CB = ((0.00378.*One'*(1-(1./(exp(0.09132.*PM_25')))))').*CB_Pop;
% CB_PM25 = sum(sum(Cases_CB.*WTP_Morb));
% Spatial_Morb = Cases_CB.*WTP_Morb;