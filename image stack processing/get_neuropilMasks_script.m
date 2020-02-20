clearvars;
tic;

data_dir = 'J:\Data & Analysis\Rule Switching';
% [dirs,expData] = expData_RuleSwitching(data_dir);
[dirs, expData] = expData_RuleSwitching_DEVO(pathlist_RuleSwitching);
[calculate, summarize, figures, mat_file, params] = params_RuleSwitching(dirs,expData);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append

%Get the masks and save in original ROI files
subtractmaskRadii = [0,2];
for i = 1:numel(expData)
    roi_dir = fullfile(dirs.data,expData(i).sub_dir,expData(i).roi_dir);
    get_neuropilMasks(roi_dir,subtractmaskRadii);
end

toc