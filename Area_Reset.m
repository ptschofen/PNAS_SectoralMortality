NH3 (:,1)   =         1.06.*(28761.72.*(Area_Source {4,1}(:,1)')*(NH4_Cal.*(Area_Source {5,1})))';
NOx (:,1) =           1.35.*(28761.72.*(Area_Source {4,1}(:,2)')*(NOx_Cal.*(Area_Source {1,1})))';
PM_25_Primary (:,1) =       (28761.72.*(Area_Source {4,1}(:,4)')*(PM25_Cal.*(Area_Source {2,1})))';
SO2 (:,1)   =         1.50.*(28761.72.*(Area_Source {4,1}(:,5)')*(SO2_Cal.*(Area_Source {3,1})))';

A_VOC (:,1) =               (28761.72.*(VOC_Cal.*Area_Source {4,1}(:,6)')*(Area_Source {2,1}))';
%B_VOC (:,1) =               (28761.72.*(0.01.*Area_Source {4,1}(:,7)')*(Area_Source {2,1}))';

