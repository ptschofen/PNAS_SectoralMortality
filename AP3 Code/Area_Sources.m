% (* ::Package:: *)

% Area Sources

I = eye (3109,3109);
%Area_Source{4,1}(:,9) = Area_Source{4,1}(:,4)- (Area_Source{4,1}(:,8));
%% NOx NO3

run Area_Reset
NOx_Area_Source = 28761.72.*1.35.*NOx_Cal.*(Area_Source {1,1});
p = 1;
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Area_Source {4,1}(:,2)'+I (n,:));
    NOx (:,1) = ((Emission_Plus)*(NOx_Area_Source))';

 run Nitrate_Sulfate_Ammonium_Marginal_New
 run PM_25_Health
% run Population_Weighted_Exposure

% D_PM_A{1,1}(n,:) = (PM_25 - PM_25_B)';
% MD_Mat{1,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	NOx_A(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    NOx_A(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
 clear NOx_Area_Source

 
%% Primary PM 25 
run Area_Reset
p = 2;
PM_Area_Source = 28761.72.*PM25_Cal.*(Area_Source {2,1});
for n = 1:S;   
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Area_Source {4,1}(:,4)'+I (n,:));
    PM_25_Primary (:,1) = ((Emission_Plus)*(PM_Area_Source))';                         
       
    run Nitrate_Sulfate_Ammonium_Marginal_New
    run PM_25_Health
    
if Model_Morbidity == 1;
	PM_25_A(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{1,1}];
    PM_25_A(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear PM_Area_Source


%% SO2 SO4

run Area_Reset
p = 3;
SO2_Area_Source = 28761.72.*1.5.*SO2_Cal.*(Area_Source {3,1});
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Area_Source {4,1}(:,5)'+I (n,:));
    SO2 (:,1) = ((Emission_Plus)*(SO2_Area_Source))';
    
    run Nitrate_Sulfate_Ammonium_Marginal_New
run PM_25_Health
%run Population_Weighted_Exposure
% SO2_A(n,1) = sum(sum(Damages));

% D_PM_A{3,1}(n,:) = (PM_25 - PM_25_B)';
% MD_Mat{3,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	SO2_A(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    SO2_A(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear SO2_Area_Source
%% NH3 NH4

run Area_Reset
% run Area_Reset_Stress_Test
p = 4;
NH3_Area_Source = 28761.72.*1.06.*NH4_Cal.*(Area_Source {5,1});
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Area_Source {4,1}(:,1)'+I (n,:));
% 50% Reduction to baseline emissions for MD Stress Test
% %     Emission_Plus = (0.50.*(Area_Source {4,1}(:,1)')+I (n,:));
    NH3 (:,1) = ((Emission_Plus)*(NH3_Area_Source))';    
     
   % run Ammonium_Excess
 run Nitrate_Sulfate_Ammonium_Marginal_New     
 run PM_25_Health
% run Population_Weighted_Exposure
% Damages = D_PWE;

% run Own_County_Share
% run Own_State_Share
    
% D_PM_A{4,1}(n,:) = (PM_25 - PM_25_B)';
%MD_Mat{4,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	NH3_A(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    NH3_A(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end

clear Damages
end
clear NH3_Area_Source
%% VOC

run Area_Reset
% run Area_Reset_Stress_Test
p = 5;
for n = 1:S;
    display(sprintf('p %d,n %d,m %d', n,p));
    Emission_Plus = (Area_Source {4,1}(:,6)'+I (n,:));
    A_VOC (:,1) = (28761.72.*(VOC_Cal.*Emission_Plus)*(Area_Source {2,1}))';    
     
    %run Ammonium_Excess
 run Nitrate_Sulfate_Ammonium_Marginal_New      
 run PM_25_Health
%run Population_Weighted_Exposure
%VOC_A(n,1) = sum(sum(Damages));

% run Own_County_Share
% run Own_State_Share
    
% D_PM_A{5,1}(n,:) = (PM_25 - PM_25_B);
% % MD_Mat{5,1}(n,:) = sum(((Spatial_Mort_Add+Spatial_Morb)-(Spatial_Mort_B+Spatial_Morb_B))');
if Model_Morbidity == 1;
	VOC_A(n,1) = sum(sum(CB_PM25 - CB_PM25_B));
else
    Damages = [All_Mort{Cause,1}];
    VOC_A(n,1) = ((sum(sum(Damages)))) - B_25_Primary_MD;
end
clear Damages
end

