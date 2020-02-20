clearvars;
tic;

%% Set MATLAB path and get experiment-specific parameters
% [dirs, expData] = expData_smLearning(pathlist_smLearning);
[dirs, expData] = expData_smLearning_DEVO(pathlist_smLearning); %For processing/troubleshooting subsets
[calculate, summarize, figures, mat_file, params] = params_smLearning(dirs,expData);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append additional paths for imaging data if required by 'calculate'

%% Fixed Parameters
subtractmaskRadii = [0,2];

%% Get the masks and save in original ROI files
for i = 1:numel(expData)
    roi_dir = fullfile(dirs.data,expData(i).sub_dir,expData(i).roi_dir);
    get_neuropilMasks(roi_dir,subtractmaskRadii);
end

toc