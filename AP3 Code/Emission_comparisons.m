% Take emissions loaded into AP3 and compute totals, write to .csv file

Emissions=zeros(5, 10);
for i = 1:7;
    Emissions(1,i)=sum((Area_Source{4,1}(:,i)));
end

for i = 1:6;
    Emissions(2,i)=sum((Low_Stack{4,1}(:,i)));
end

for i = 1:6;
    Emissions(3,i)=sum((Med_Stack{4,1}(:,i)));
end

for i = 1:6;
    Emissions(4,i)=sum((Tall_Stack{4,1}(:,i)));
end

for i = 1:6;
    Emissions(5,i)=sum((New_Tall{4,1}(:,i)));
end
%dlmwrite('emissions_2014.csv', Emissions, 'precision', 12) %%%
dlmwrite('md_A_2008.csv', Mort_D_A, 'precision', 12) %%%
dlmwrite('md_L_2008.csv', Mort_D_L, 'precision', 12) %%%
dlmwrite('md_M_2008.csv', Mort_D_M, 'precision', 12) %%%
dlmwrite('md_T_2008.csv', Mort_D_T, 'precision', 12) %%%
dlmwrite('md_T2_2008.csv', Mort_D_T2, 'precision', 12) %%%