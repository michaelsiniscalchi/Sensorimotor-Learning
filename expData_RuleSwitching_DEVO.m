function [ dirs, expData ] = expData_RuleSwitching_DEVO(data_dir)

%PURPOSE: Create data structure for imaging tiff files and behavioral log files
%AUTHORS: AC Kwan, 170519.
%
%INPUT ARGUMENTS
%   data_dir:    The base directory to which the raw data are stored.  
%
%OUTPUT VARIABLES
%   dirs:        The subfolder structure within data_dir to work with
%   expData:     Info regarding each experiment

dirs.data = fullfile(data_dir,'Data');
dirs.results = fullfile(data_dir,'Results');
dirs.summary = fullfile(data_dir,'Summary');
dirs.figures = fullfile(data_dir,'Figures');

%% SST+ Interneurons (n=15)
i=1;

expData(i).sub_dir = '170929 M48 RuleSwitching'; 
expData(i).logfile = 'M48_RULESWITCHING_1709291124.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;

% expData(i).sub_dir = '170928 M47 RuleSwitching'; 
% expData(i).logfile = 'M47_RULESWITCHING_1709281709.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171012 M47 RuleSwitching'; 
% expData(i).logfile = 'M47_RULESWITCHING_1710121657.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171114 M47 RuleSwitching'; 
% expData(i).logfile = 'M47_RULESWITCHING_1711141445.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171024 M47 RuleSwitching'; 
% expData(i).logfile = 'M47_RULESWITCHING_1710241601.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171103 M47 RuleSwitching'; 
% expData(i).logfile = 'M47_RULESWITCHING_1711031516.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '170929 M48 RuleSwitching'; 
% expData(i).logfile = 'M48_RULESWITCHING_1709291124.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171013 M48 RuleSwitching'; 
% expData(i).logfile = 'M48_RULESWITCHING_1710131613.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171112 M49 RuleSwitching'; 
% expData(i).logfile = 'M49_RULESWITCHING_1711121311.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1; 
% expData(i).sub_dir = '171101 M49 RuleSwitching';  % ***NEEDED SPECIALIZED PROCESSING: TRUNCATED TO TRIAL 367... 
% expData(i).logfile = 'M49_RULESWITCHING_1711011702.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% 
% i = i+1;
% expData(i).sub_dir = '171011 M50 RuleSwitching'; 
% expData(i).logfile = 'M50_RULESWITCHING_1710111555.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171014 M50 RuleSwitching'; 
% expData(i).logfile = 'M50_RULESWITCHING_1710141243.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171027 M50 RuleSwitching'; 
% expData(i).logfile = 'M50_RULESWITCHING_1710271654.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% % i = i+1;
% % expData(i).sub_dir = '171005 M50 RuleSwitching'; %**Large (1-10s) discrepancy between ITI_beh vs ITI_img
% % expData(i).logfile = 'M50_RULESWITCHING_1710051344.log';
% % expData(i).cellType = 'SST'; %Cell-type label 
% % expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171103 M51 RuleSwitching'; 
% expData(i).logfile = 'M51_RULESWITCHING_1711031705.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% i = i+1;
% expData(i).sub_dir = '171109 M51 RuleSwitching'; 
% expData(i).logfile = 'M51_RULESWITCHING_1711091542.log';
% expData(i).cellType = 'SST'; %Cell-type label 
% expData(i).npCorrFactor = 0.5;
% 
% %% VIP+ Interneurons (N=20)
% i = i+1;
% expData(i).sub_dir = '180927 M57 RuleSwitching'; 
% expData(i).logfile = 'M57_RULESWITCHING_1809271436.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181010 M57 RuleSwitching'; 
% expData(i).logfile = 'M57_RULESWITCHING_1810101343.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181012 M57 RuleSwitching'; 
% expData(i).logfile = 'M57_RULESWITCHING_1810121437.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181026 M57 Ruleswitching'; 
% expData(i).logfile = 'M57_RULESWITCHING_1810261247.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% 
% i = i+1;
% expData(i).sub_dir = '181023 M58 Ruleswitching'; 
% expData(i).logfile = 'M58_RULESWITCHING_1810231352.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181025 M58 Ruleswitching'; 
% expData(i).logfile = 'M58_RULESWITCHING_1810251553.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181030 M58 Ruleswitching'; 
% expData(i).logfile = 'M58_RULESWITCHING_1810301204.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% 
% i = i+1;
% expData(i).sub_dir = '181016 M59 RuleSwitching'; 
% expData(i).logfile = 'M59_RULESWITCHING_1810161240.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181017 M59 RuleSwitching'; 
% expData(i).logfile = 'M59_RULESWITCHING_1810171336.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181019 M59 Ruleswitching'; 
% expData(i).logfile = 'M59_RULESWITCHING_1810191524.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181024 M59 Ruleswitching'; 
% expData(i).logfile = 'M59_RULESWITCHING_1810241348.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181025 M59 Ruleswitching'; 
% expData(i).logfile = 'M59_RULESWITCHING_1810251151.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% 
% i = i+1;
% expData(i).sub_dir = '181016 M60 RuleSwitching'; 
% expData(i).logfile = 'M60_RULESWITCHING_1810161547.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181023 M60 Ruleswitching'; 
% expData(i).logfile = 'M60_RULESWITCHING_1810231536.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181025 M60 Ruleswitching'; 
% expData(i).logfile = 'M60_RULESWITCHING_1810251345.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181026 M60 Ruleswitching'; 
% expData(i).logfile = 'M60_RULESWITCHING_1810261530.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181030 M60 Ruleswitching'; 
% expData(i).logfile = 'M60_RULESWITCHING_1810301348.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% 
% i = i+1;
% expData(i).sub_dir = '181027 M61 Ruleswitching'; 
% expData(i).logfile = 'M61_RULESWITCHING_1810271430.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% i = i+1;
% expData(i).sub_dir = '181031 M61 Ruleswitching'; 
% expData(i).logfile = 'M61_RULESWITCHING_1810311203.log';
% expData(i).cellType = 'VIP'; %Cell-type label 
% expData(i).npCorrFactor = 0;
% 
% %% PV+ Interneurons (N=12?)
% %Z-drift problematic, especially in sessions from M42 & M43. 
% %Add field: expData(i).excludeFrames used for specifying frames encompassing z-drift corrections. 
% %Modify calc_dFF to set as NaN, and then separately calculate dF/F for segments bounded by NaN...
% 
% i = i+1;
% expData(i).sub_dir = '171018 M42 RuleSwitching'; %**Inconsistency: numel(logfileTimes)<numel(stackInfo.rawFileName)
% expData(i).logfile = 'M42_RULESWITCHING_1710181514.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '171104 M42 RuleSwitching'; 
% expData(i).logfile = 'M42_RULESWITCHING_1711041150.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '171113 M42 RuleSwitching'; %**Inconsistency: numel(logfileTimes)<numel(stackInfo.rawFileName)
% expData(i).logfile = 'M42_RULESWITCHING_1711131547.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% i = i+1;
% expData(i).sub_dir = '171012 M43 RuleSwitching'; 
% expData(i).logfile = 'M43_RULESWITCHING_1710121336.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '171019 M43 RuleSwitching'; %**Inconsistency: numel(logfileTimes)<numel(stackInfo.rawFileName)
% expData(i).logfile = 'M43_RULESWITCHING_1710191631.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '171027 M43 RuleSwitching';  %Done **Inconsistency: numel(logfileTimes)<numel(stackInfo.rawFileName)
% expData(i).logfile = 'M43_RULESWITCHING_1710271515.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '171102 M43 RuleSwitching'; %Done
% expData(i).logfile = 'M43_RULESWITCHING_1711021416.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% i = i+1;
% expData(i).sub_dir = '190503 M62 Ruleswitching'; 
% expData(i).logfile = 'M62_RULESWITCHING_1905031303.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '190508 M62 Ruleswitching'; %Drift corr apparent in some traces
% expData(i).logfile = 'M62_RULESWITCHING_1905081110.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '190517 M62 Ruleswitching'; 
% expData(i).logfile = 'M62_RULESWITCHING_1905171303.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '190522 M62 Ruleswitching'; 
% expData(i).logfile = 'M62_RULESWITCHING_1905221233.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '190620 M62 Ruleswitching'; %NOTE: incorrect date on imaging filenames.
% expData(i).logfile = 'M62_RULESWITCHING_1906211523.log';
% expData(i).cellType = 'PV'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% %% CamKIIa+ Neurons (N = 16)
% 
% i = i+1;
% expData(i).sub_dir = '181003 M52 RuleSwitching'; 
% expData(i).logfile = 'M52_RULESWITCHING_1810031347.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '181005 M52 RuleSwitching'; 
% expData(i).logfile = 'M52_RULESWITCHING_1810051423.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '181009 M52 RuleSwitching'; % Processed through transition results 200116; Need Figures!!
% expData(i).logfile = 'M52_RULESWITCHING_1810091211.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% i = i+1;
% expData(i).sub_dir = '180919 M53 RuleSwitching'; 
% expData(i).logfile = 'M53_RULESWITCHING_1809191042.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180925 M53 RuleSwitching'; % Processed through transition results 200116; Need Figures!!
% expData(i).logfile = 'M53_RULESWITCHING_1809251557.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180928 M53 RuleSwitching'; % Processed through transition results 200116; Need Figures!!
% expData(i).logfile = 'M53_RULESWITCHING_1809281027.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% i = i+1;
% expData(i).sub_dir = '180829 M54 RuleSwitching'; 
% expData(i).logfile = 'M54_RULESWITCHING_1808291308.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180905 M54 RuleSwitching'; % Processed through transition results 200116; Need Figures!!
% expData(i).logfile = 'M54_RULESWITCHING_1809051526.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180912 M54 RuleSwitching'; % Processed through transition results 200116; Need Figures!! 
% expData(i).logfile = 'M54_RULESWITCHING_1809121331.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% i = i+1;
% expData(i).sub_dir = '180831 M55 RuleSwitching'; 
% expData(i).logfile = 'M55_RULESWITCHING_1808311318.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180905 M55 RuleSwitching'; 
% expData(i).logfile = 'M55_RULESWITCHING_1809051333.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180918 M55 RuleSwitching'; 
% expData(i).logfile = 'M55_RULESWITCHING_1809181521.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180920 M55 RuleSwitching'; 
% expData(i).logfile = 'M55_RULESWITCHING_1809201612.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% 
% i = i+1;
% expData(i).sub_dir = '180830 M56 RuleSwitching'; 
% expData(i).logfile = 'M55_RULESWITCHING_1808311318.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180906 M56 RuleSwitching'; 
% expData(i).logfile = 'M56_RULESWITCHING_1809061310.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180921 M56 RuleSwitching'; 
% expData(i).logfile = 'M56_RULESWITCHING_1809211356.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;

% i = i+1;
% expData(i).sub_dir = '180907 M55 RuleSwitching'; 
% expData(i).logfile = 'M55_RULESWITCHING_1809071427.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180918 M54 RuleSwitching'; 
% expData(i).logfile = 'M54_RULESWITCHING_1809181228.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '180921 M54 RuleSwitching'; 
% expData(i).logfile = 'M54_RULESWITCHING_1809211136.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;
% i = i+1;
% expData(i).sub_dir = '181011 M52 RuleSwitching'; 
% expData(i).logfile = 'M52_RULESWITCHING_1810111445.log';
% expData(i).cellType = 'PYR'; %Cell-type label 
% expData(i).npCorrFactor = 0.3;




%---------------------------------------------------------------------------------------------------
% ***FOLLOWING MOVED to separate function: '...\image stack processing\get_imgPaths.m'***
% %% Get ROI directories and define paths to imaging data 
% 
% for i = 1:numel(expData)
%     dir_list = dir(fullfile(dirs.data,expData(i).sub_dir,'ROI*'));
%     expData(i).roi_dir = dir_list.name; %Full path to ROI directory
%     expData = get_imgPathnames(dirs,expData,i); %Get pathnames to raw, registered, and matfiles
% end