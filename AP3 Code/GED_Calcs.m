%Area Sources
GED_A=zeros(S, 5);
%NH3
GED_A(:,1)=Mort_D_A(:,1).*(Area_Source {4,1}(:,1));
%NOx
GED_A(:,2)=Mort_D_A(:,2).*(Area_Source {4,1}(:,2));
%PM2.5
GED_A(:,3)=Mort_D_A(:,3).*(Area_Source {4,1}(:,4));
%SO2
GED_A(:,4)=Mort_D_A(:,4).*(Area_Source {4,1}(:,5));
%VOC
GED_A(:,5)=Mort_D_A(:,5).*(Area_Source {4,1}(:,6));

%Low Stacks
GED_L=zeros(S, 5);
%NH3
GED_L(:,1)=Mort_D_L(:,1).*(Low_Stack {4,1}(:,1));
%NOx
GED_L(:,2)=Mort_D_L(:,2).*(Low_Stack {4,1}(:,2));
%PM2.5
GED_L(:,3)=Mort_D_L(:,3).*(Low_Stack {4,1}(:,4));
%SO2
GED_L(:,4)=Mort_D_L(:,4).*(Low_Stack {4,1}(:,5));
%VOC
GED_L(:,5)=Mort_D_L(:,5).*(Low_Stack {4,1}(:,6));

%Medium Stacks
GED_M=zeros(S, 5);
%NH3
GED_M(:,1)=Mort_D_M(:,1).*(Med_Stack {4,1}(:,1));
%NOx
GED_M(:,2)=Mort_D_M(:,2).*(Med_Stack {4,1}(:,2));
%PM2.5
GED_M(:,3)=Mort_D_M(:,3).*(Med_Stack {4,1}(:,4));
%SO2
GED_M(:,4)=Mort_D_M(:,4).*(Med_Stack {4,1}(:,5));
%VOC
GED_M(:,5)=Mort_D_M(:,5).*(Med_Stack {4,1}(:,6));

%Tall Stacks
GED_T=zeros(T, 5);
%NH3
GED_T(:,1)=Mort_D_T(:,1).*(Tall_Stack {4,1}(:,1));
%NOx
GED_T(:,2)=Mort_D_T(:,2).*(Tall_Stack {4,1}(:,2));
%PM2.5
GED_T(:,3)=Mort_D_T(:,3).*(Tall_Stack {4,1}(:,4));
%SO2
GED_T(:,4)=Mort_D_T(:,4).*(Tall_Stack {4,1}(:,5));
%VOC
GED_T(:,5)=Mort_D_T(:,5).*(Tall_Stack {4,1}(:,6));

%Tall2 Stacks
GED_T2=zeros(T2, 5);
%NH3
GED_T2(:,1)=Mort_D_T2(:,1).*(New_Tall {4,1}(:,1));
%NOx
GED_T2(:,2)=Mort_D_T2(:,2).*(New_Tall {4,1}(:,2));
%PM2.5
GED_T2(:,3)=Mort_D_T2(:,3).*(New_Tall {4,1}(:,4));
%SO2
GED_T2(:,4)=Mort_D_T2(:,4).*(New_Tall {4,1}(:,5));
%VOC
GED_T2(:,5)=Mort_D_T2(:,5).*(New_Tall {4,1}(:,6));

%Summing Up
GED_Tot=zeros(1, 5);
%NH3
GED_Tot(1,1)=sum(GED_A(:,1))+sum(GED_L(:,1))+sum(GED_M(:,1))+sum(GED_T(:,1))+sum(GED_T2(:,1));
%NOx
GED_Tot(1,2)=sum(GED_A(:,2))+sum(GED_L(:,2))+sum(GED_M(:,2))+sum(GED_T(:,2))+sum(GED_T2(:,2));
%PM2.5
GED_Tot(1,3)=sum(GED_A(:,3))+sum(GED_L(:,3))+sum(GED_M(:,3))+sum(GED_T(:,3))+sum(GED_T2(:,3));
%SO2
GED_Tot(1,4)=sum(GED_A(:,4))+sum(GED_L(:,4))+sum(GED_M(:,4))+sum(GED_T(:,4))+sum(GED_T2(:,4));
%VOC
GED_Tot(1,5)=sum(GED_A(:,5))+sum(GED_L(:,5))+sum(GED_M(:,5))+sum(GED_T(:,5))+sum(GED_T2(:,5));



%GED in billions
GED=sum(GED_Tot(1,:))/10^9

% GED ARea sources
GED_Area=(sum(GED_A(:,1))+sum(GED_A(:,2))+sum(GED_A(:,3))+sum(GED_A(:,4))+sum(GED_A(:,5)))/10^9

% GED Facilities\
GED_Facilities=GED-GED_Area

%Fractions of Pollutants
GED_fractions=GED_Tot./(GED*10^9)

%---
% other stuff
% Marginal Damages Average
MD_AVG=zeros(5,5);
MD_AVG(1,:)=mean(Mort_D_A);
MD_AVG(2,:)=mean(Mort_D_L);
MD_AVG(3,:)=mean(Mort_D_M);
MD_AVG(4,:)=mean(Mort_D_T);
MD_AVG(5,:)=mean(Mort_D_T2);

% Emissions
% Area Sources
NH3_A=sum((Area_Source {4,1}(:,1)));
NOx_A=sum((Area_Source {4,1}(:,2)));
PM_A=sum((Area_Source {4,1}(:,4)));
SO2_A=sum((Area_Source {4,1}(:,5)));
VOC_A=sum((Area_Source {4,1}(:,6)));
% Low Stack
NH3_L=sum((Low_Stack {4,1}(:,1)));
NOx_L=sum((Low_Stack {4,1}(:,2)));
PM_L=sum((Low_Stack {4,1}(:,4)));
SO2_L=sum((Low_Stack {4,1}(:,5)));
VOC_L=sum((Low_Stack {4,1}(:,6)));
% Medium Stack
NH3_M=sum((Med_Stack {4,1}(:,1)));
NOx_M=sum((Med_Stack {4,1}(:,2)));
PM_M=sum((Med_Stack {4,1}(:,4)));
SO2_M=sum((Med_Stack {4,1}(:,5)));
VOC_M=sum((Med_Stack {4,1}(:,6)));
% Tall Stack
NH3_T=sum((Tall_Stack {4,1}(:,1)));
NOx_T=sum((Tall_Stack {4,1}(:,2)));
PM_T=sum((Tall_Stack {4,1}(:,4)));
SO2_T=sum((Tall_Stack {4,1}(:,5)));
VOC_T=sum((Tall_Stack {4,1}(:,6)));
% Tall Stack 2
NH3_T2=sum((New_Tall {4,1}(:,1)));
NOx_T2=sum((New_Tall {4,1}(:,2)));
PM_T2=sum((New_Tall {4,1}(:,4)));
SO2_T2=sum((New_Tall {4,1}(:,5)));
VOC_T2=sum((New_Tall {4,1}(:,6)));
% Summing Up
Emissions=[NH3_A, NOx_A, PM_A, SO2_A, VOC_A; NH3_L, NOx_L, PM_L, SO2_L, VOC_L; NH3_M, NOx_M, PM_M, SO2_M, VOC_M; NH3_T, NOx_T, PM_T, SO2_T, VOC_T; NH3_T2, NOx_T2, PM_T2, SO2_T2, VOC_T2];

% MD_Avg*Emissions Calcs
GED_check=MD_AVG.*Emissions;

% Summing and Fractions
GED_check_NH3=sum(GED_check(:,1));
GED_check_NOx=sum(GED_check(:,2));
GED_check_PM=sum(GED_check(:,3));
GED_check_SO2=sum(GED_check(:,4));
GED_check_VOC=sum(GED_check(:,5));
GED_check_Tot=sum(sum(GED_check));
GED_check_fractions=sum(GED_check)/GED_check_Tot;

% Comparing the two methods
GED_comp=[GED_fractions;GED_check_fractions]