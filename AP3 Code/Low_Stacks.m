% (* ::Package:: *)

% Low Stacks

%% NOx NO3

run Area_Reset
% run Area_Reset_Stress_Test
run Low_Reset
% run Low_Reset_Stress_Test
NOx_Low_Stack = 28761.72.*1.35.*NOx_Cal.*Low_Stack{1,1};
p = 6;
for n = 1:S; 
    display(sprintf('p %d,n %d,m %d', n,p));  
    Emission_Plus = (Low_Stack {4,1}(:,2)'+I (n,:));
    NOx (:,2) = ((Emission_Plus)*(NOx_Low_Stack))';

run Nitrate_Sulfate_Ammonium_Marginal_New     
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
%D_PM_L{1,1}(n,1) = sum(sum(PM_25 - PM_25_B));
if Model_Morbidity == 1;
	NOx_L(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    NOx_L(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear NOx_Low_Stack
%% Primary PM 25

run Low_Reset
% run Low_Reset_Stress_Test
PM_Low_Stack = 28761.72.*PM25_Cal.*(Low_Stack {2,1});
p = 7;
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Low_Stack {4,1}(:,4)'+I (n,:));
    PM_25_Primary (:,2) =((Emission_Plus)*(PM_Low_Stack))';
    
    run Nitrate_Sulfate_Ammonium_Marginal_New    
    run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
%D_PM_L{2,1}(n,1) = sum(sum(PM_25 - PM_25_B));
if Model_Morbidity == 1;
	PM_25_L(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    PM_25_L(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end


%% SO2_SO4

run Low_Reset
% run Low_Reset_Stress_Test
SO2_Low_Stack = 28761.72.*1.5.*SO2_Cal.*(Low_Stack {3,1});
p = 8;
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Low_Stack {4,1}(:,5)'+I (n,:));
    SO2 (:,2) = ((Emission_Plus)*(SO2_Low_Stack))';
  
    run Nitrate_Sulfate_Ammonium_Marginal_New   
    run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
% D_PM_L{3,1}(n,1) = sum(sum(PM_25 - PM_25_B));
if Model_Morbidity == 1;
	SO2_L(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    SO2_L(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

    clear Damages
end

%% NH3 NH4

run Low_Reset
% run Low_Reset_Stress_Test
NH3_Low_Stack = 28761.72.*1.06.*NH4_Cal.*(Low_Stack {5,1});
p = 9;
for n = 1:S;  
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Low_Stack {4,1}(:,1)'+I (n,:));
    NH3 (:,2) = ((Emission_Plus)*(NH3_Low_Stack))';    
   
    run Nitrate_Sulfate_Ammonium_Marginal_New    
    run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
%D_PM_L{4,1}(n,1) = sum(sum(PM_25 - PM_25_B));
if Model_Morbidity == 1;
	NH3_L(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    NH3_L(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

    clear Damages
end

%% VOC

run Low_Reset
% run Low_Reset_Stress_Test
p = 10;
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Low_Stack {4,1}(:,6)'+I (n,:));
    A_VOC (:,2) = (28761.72.*(VOC_Cal.*Emission_Plus)*(Low_Stack {2,1}))';    
     
run Nitrate_Sulfate_Ammonium_Marginal_New   
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
%D_PM_L{5,1}(n,1) = sum(sum(PM_25 - PM_25_B));
if Model_Morbidity == 1;
	VOC_L(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    VOC_L(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end

run Low_Reset
% run Low_Reset_Stress_Test
clear I
