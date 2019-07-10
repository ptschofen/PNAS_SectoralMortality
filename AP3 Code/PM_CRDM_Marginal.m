        
%% Activate the following scripts for Full Deterministic Model
     tic
     run PM_Setup
     run Population
     run PM_Base_Conc
     
% Potentially change to smaller number of runs for quick model checks
%      S=5;
%      T=5;
%      T2=5;
      run Mortality_script
      run Damages
      run Garbage_Disposal
      run GED_Calcs
      run Emission_comparisons
      toc
      beep