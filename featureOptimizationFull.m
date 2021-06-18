%% N10

brem = false;
npks = 1;
nplt = 0;
featureCalibration_func(brem, npks, nplt);
disp('completed preprocessing of N10')
featSelSFFS_func(brem, npks, nplt);
disp('completed SFFS of N10')
MDS_func(1, brem, npks, nplt)
disp('completed MDS of N10')

%% N11

brem = false;
npks = 1;
nplt = 1;
featureCalibration_func(brem, npks, nplt);
disp('completed preprocessing of N11')
featSelSFFS_func(brem, npks, nplt);
disp('completed SFFS of N11')
MDS_func(1, brem, npks, nplt)
disp('completed MDS of N11')

%% N20

brem = false;
npks = 2;
nplt = 0;
featureCalibration_func(brem, npks, nplt);
disp('completed preprocessing of N20')
featSelSFFS_func(brem, npks, nplt);
disp('completed SFFS of N20')
MDS_func(1, brem, npks, nplt)
disp('completed MDS of N20')

%% Y10

brem = true;
npks = 1;
nplt = 0;
featureCalibration_func(brem, npks, nplt);
disp('completed preprocessing of Y10')
featSelSFFS_func(brem, npks, nplt);
disp('completed SFFS of Y10')
MDS_func(1, brem, npks, nplt)
disp('completed MDS of Y10')

%% sans

%featureCalibration_func();
%disp('completed preprocessing of sans')
%featSelSFFS_func();
%disp('completed SFFS of sans')
%MDS_func(1)
%disp('completed MDS of sans')


