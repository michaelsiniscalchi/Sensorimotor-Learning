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
expData(i).sub_dir = '180425 M54 Discrim50_DEVO'; 
expData(i).logfile = 'M54_DISCRIM_1804251531.log';
expData(i).criterion = 55;
expData(i).npCorrFactor = 0.5;

% i=i+1;
% expData(i).sub_dir = '180419 M52 Discrim50'; 
% expData(i).logfile = 'M52_DISCRIM_1804191507.log';
% expData(i).criterion = 0; %Zero indicates the <55% session.
% expData(i).npCorrFactor = 0.5;
% i=i+1;
% expData(i).sub_dir = '180424 M52 Discrim60'; 
% expData(i).logfile = 'M52_DISCRIM_1804241617.log';
% expData(i).criterion = 55; %Zero indicates the <55% session.
% expData(i).npCorrFactor = 0.5;

