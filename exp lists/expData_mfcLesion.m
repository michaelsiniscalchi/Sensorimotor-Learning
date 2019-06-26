function [ dirs, expData ] = expData_mfcLesion(data_dir)

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

%Data in subdirectories by experimental subject
dir_list = dir(dirs.data);
dir_list = dir_list(~strcmp({dir_list.name},'.') & ~strcmp({dir_list.name},'..'));

k = 1; %counter
for i = 1:numel(dir_list)
    file_list = dir(fullfile(dir_list(i).folder,dir_list(i).name,'*.log'));
    for j = 1:numel(file_list)
        expData(k).sub_dir = dir_list(i).name;
        expData(k).logfile = file_list(j).name;
        k = k+1;
    end
end