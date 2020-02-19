function [ dirs, expData ] = expData_smLearning(data_dir)

%PURPOSE: Create data structure for imaging tiff files and behavioral log files
%AUTHORS: AC Kwan, 170519.
%
%INPUT ARGUMENTS
%   data_dir:    The base directory to which the raw data are stored.  
%
%OUTPUT VARIABLES
%   dirs:        The subfolder structure within data_dir to work with
%   expData:     Info regarding each experiment

dirs.data = fullfile(data_dir,'data');
dirs.analysis = fullfile(data_dir,'analysis');
dirs.summary = fullfile(data_dir,'summary');

i=1;
expData(i).sub_dir = '180419 M52 Discrim50'; 
expData(i).logfile = 'M52_DISCRIM_1804191507.log';
expData(i).criterion = 0; %Zero indicates the <55% session.
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180424 M52 Discrim60'; 
expData(i).logfile = 'M52_DISCRIM_1804241617.log';
expData(i).criterion = 55; %Zero indicates the <55% session.
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180428 M52 Discrim70'; 
expData(i).logfile = 'M52_DISCRIM_1804281151.log';
expData(i).criterion = 65; %Zero indicates the <55% session.
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180502 M52 Discrim80'; 
expData(i).logfile = 'M52_DISCRIM_1805021637.log';
expData(i).criterion = 75; %Zero indicates the <55% session.
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180524 M52 Discrim90'; 
expData(i).logfile = 'M52_DISCRIM_1805241249.log';
expData(i).criterion = 85; %Zero indicates the <55% session.
expData(i).npCorrFactor = 0.5;



i=i+1;
expData(i).sub_dir = '180422 M54 Discrim'; 
expData(i).logfile = 'M54_DISCRIM_1804221252.log';
expData(i).criterion = 0; %Zero indicates the <55% session.
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180425 M54 Discrim50'; 
expData(i).logfile = 'M54_DISCRIM_1804251531.log';
expData(i).criterion = 55;
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180501 M54 Discrim60';
expData(i).logfile = 'M54_DISCRIM_1805011711.log';
expData(i).criterion = 65;
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180503 M54 Discrim70';
expData(i).logfile = 'M54_DISCRIM_1805031615.log';
expData(i).criterion = 75;
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180505 M54 Discrim80';
expData(i).logfile = 'M54_DISCRIM_1805051654.log';
expData(i).criterion = 85;
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180427 M54 Discrim60'; %Not used currently for performance threshold-crossing based analyses
expData(i).logfile = 'M54_DISCRIM_1804271304.log';
expData(i).criterion = NaN;
expData(i).npCorrFactor = 0.5;
i=i+1;
expData(i).sub_dir = '180515 M54 Discrim90'; %Not used currently for performance threshold-crossing based analyses
expData(i).logfile = 'M54_DISCRIM_1805151318.log';
expData(i).criterion = NaN;
expData(i).npCorrFactor = 0.5;

%---For Code Development---------------------------------------------------
% i=i+1;
% expData(i).sub_dir = '180425 M54 Discrim50 devSet'; 
% expData(i).logfile = 'M54_DISCRIM_1804251531.log';
% expData(i).criterion = 55;
% expData(i).npCorrFactor = 0.5;

% i=i+1;
% expData(i).sub_dir = '180530 M54 Discrim90';
% expData(i).logfile = 'M54_DISCRIM_1805301337.log';
% expData(i).criterion = 90;
% expData(i).npCorrFactor = 0.5;

for i = 1:numel(expData)
    dir_list = dir(fullfile(dirs.data,expData(i).sub_dir,'ROI*'));
    expData(i).roi_dir = dir_list.name; %Full path to ROI directory
end

  
