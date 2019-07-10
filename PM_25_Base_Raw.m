% PM_25_B(:,1) = (NO3(:,1)+SO4(:,1)+A_VOC(:,1)+A_VOC(:,2)+A_VOC(:,3)+A_VOC(:,4) + A_VOC(:,5) + PM_25_Primary(:,1) +  PM_25_Primary(:,2) + PM_25_Primary(:,3) + PM_25_Primary(:,4)+ PM_25_Primary(:,5)+ PM_25_Primary(:,6));
PM_25_B(:,1) = (NO3(:,1)+SO4(:,1)+A_VOC(:,1)+A_VOC(:,2)+A_VOC(:,3)+A_VOC(:,4) + A_VOC(:,5) +B_VOC(:, 1) + PM_25_Primary(:,1) +  PM_25_Primary(:,2) + PM_25_Primary(:,3) + PM_25_Primary(:,4)+ PM_25_Primary(:,5)+NH4);
%PM_25_B(:,1) = (NO3(:,1)+SO4(:,1)+A_VOC(:,1)+A_VOC(:,2)+A_VOC(:,3)+A_VOC(:,4) + A_VOC(:,5) +PM_25_Primary(:,1) +  PM_25_Primary(:,2) + PM_25_Primary(:,3) + PM_25_Primary(:,4)+ PM_25_Primary(:,5));

%PM_10_B(:,1) = (NO3(:,1)+SO4(:,1)+A_VOC(:,1)+A_VOC(:,2)+A_VOC(:,3)+A_VOC(:,4) + A_VOC(:,5) + B_VOC(:,1)+PM_10_Primary(:,1) +  PM_10_Primary(:,2) + PM_10_Primary(:,3) + PM_10_Primary(:,4)+ PM_10_Primary(:,5));

