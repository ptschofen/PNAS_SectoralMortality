% (* ::Package:: *)

% Medium Stacks
I = eye (3109,3109);
%MD_Mat = cell(5,1); 
%%  NOx NO3

run Med_Reset
% run Med_Reset_Stress_Test
NOx_Med_Stack = 28761.72.*1.35.*NOx_Cal.*(Med_Stack {1,1});
p=11;
for n = 1:S; 
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Med_Stack {4,1}(:,2)'+I (n,:));
%     Emission_Plus = (0.50.*Med_Stack {4,1}(:,2)'+I (n,:));
    NOx (:,3) =((Emission_Plus)*((NOx_Med_Stack)))';
   
run Nitrate_Sulfate_Ammonium_Marginal_New   
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
% run Own_County_Share
% run Own_State_Share
%D_PM_M{1,1}(n,:) = ((PM_25 - PM_25_B));
% MD_Mat{1,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	NOx_M(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    NOx_M(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear NOx_Med_Stack
%% Primary PM 25

run Med_Reset
% run Med_Reset_Stress_Test
PM_Med_Stack = 28761.72.*PM25_Cal.*(Med_Stack {2,1});
p=12;
for n = 1:S; 
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Med_Stack {4,1}(:,4)'+I (n,:));
%   Emission_Plus = (0.50.*Med_Stack {4,1}(:,4)'+I (n,:));
    PM_25_Primary (:,3) =((Emission_Plus)*(PM_Med_Stack))';
    
run Nitrate_Sulfate_Ammonium_Marginal_New  
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
% run Own_County_Share
% run Own_State_Share
%D_PM_M{2,1}(n,:) = ((PM_25 - PM_25_B));
% MD_Mat{2,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	PM_25_M(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    PM_25_M(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear PM_Med_Stack
%% SO2_SO4

run Med_Reset
% run Med_Reset_Stress_Test
SO2_Med_Stack = 28761.72.*1.5.*SO2_Cal.*(Med_Stack {3,1});
p=13;
for n = 1:S; 
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Med_Stack {4,1}(:,5)'+I (n,:));
%     Emission_Plus = (0.50.*Med_Stack {4,1}(:,5)'+I (n,:));
    SO2 (:,3) = ((Emission_Plus)*(SO2_Med_Stack))';
  
run Nitrate_Sulfate_Ammonium_Marginal_New    
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
% run Own_County_Share
% run Own_State_Share
%D_PM_M{3,1}(n,:) = ((PM_25 - PM_25_B));
% MD_Mat{3,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');

if Model_Morbidity == 1;
	SO2_M(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    SO2_M(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear SO2_Med_Stack
%% NH3 NH4

run Med_Reset
% run Med_Reset_Stress_Test
NH3_Med_Stack = 28761.72.*1.06.* (NH4_Cal.*(Med_Stack {5,1}));
p=14;
for n = 1:S; 
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Med_Stack {4,1}(:,1)'+I (n,:));
%     Emission_Plus = (0.50.*Med_Stack {4,1}(:,1)'+I (n,:));
    NH3 (:,3) = ((Emission_Plus)*(NH3_Med_Stack))';    
     
run Nitrate_Sulfate_Ammonium_Marginal_New    
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
% run Own_County_Share
% run Own_State_Share
% D_PM_M{4,1}(n,1) = sum(sum(PM_25 - PM_25_B));
%MD_Mat{4,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');

if Model_Morbidity == 1;
	NH3_M(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    NH3_M(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear NH3_Med_Stack
%% VOC

run Med_Reset
% run Med_Reset_Stress_Test
VOC_Med_Stack = Med_Stack {2,1};
p=15;
for n = 1:S; 
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Med_Stack {4,1}(:,6)'+I (n,:));
%     Emission_Plus = (0.50.*Med_Stack {4,1}(:,6)'+I (n,:));
    A_VOC (:,3) = (28761.72.*(VOC_Cal.*Emission_Plus)*(VOC_Med_Stack))';    
     
run Nitrate_Sulfate_Ammonium_Marginal_New
run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;
% run Own_County_Share
% run Own_State_Share
%D_PM_M{5,1}(n,:) = ((PM_25 - PM_25_B));
% MD_Mat{5,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	VOC_M(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    VOC_M(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
