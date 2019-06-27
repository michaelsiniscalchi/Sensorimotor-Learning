%%% smLearning_setPathList 
%
%PURPOSE:   Set up paths to run all analyses of longitudinal imaging & 
%               behavior during learning of sensorimotor associations. 
%AUTHORS: MJ Siniscalchi
%
%--------------------------------------------------------------------------
function [ data_dir, code_dir, path_list ] = smLearning_setPathList

data_dir = 'C:\Users\Michael\Documents\Data & Analysis';
code_dir = 'C:\Users\Michael\Documents\MATLAB\GitHub\Sensorimotor-Learning';

% add the paths needed for this code
path_list = {...
    code_dir;...
    fullfile(code_dir,'common functions');...
    fullfile(code_dir,'common functions','cbrewer');...
    fullfile(code_dir,'exp lists');...
    fullfile(code_dir,'behavior');...
    fullfile(code_dir,'cell fluo');...
    fullfile(code_dir,'image stack processing');...
    fullfile(code_dir,'troubleshooting');...
    };
addpath(path_list{:});