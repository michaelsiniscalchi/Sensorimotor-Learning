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

dirs.data = fullfile(data_dir,'Data');
dirs.notebook = fullfile(data_dir,'Notebook'); 
dirs.results = fullfile(data_dir,'Results');
dirs.summary = fullfile(data_dir,'Summary');
dirs.figures = fullfile(data_dir,'Figures');

%% FIXED PARAMETERS FOR EACH SESSION
i=1;
expData(i).sub_dir = '170928 M47 RuleSwitching'; 
expData(i).logfile = 'M47_RULESWITCHING_1709281709.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;