%%% get_imgPaths()
%
% Purpose: To include/exclude paths to imaging data in struct 'expData'
%           -This allows use of analysis_RuleSwitching.m to run selected analyses without storing 
%               all the processed imaging data. (eg, for analyzing results remotely) 
%
%---------------------------------------------------------------------------------------------------

function expData = get_imgPaths( dirs, expData, calculate, figures )

% Get ROI directories and define paths to imaging data
C = calculate;
F = figures;
if any([C.stack_info, C.combined_data, C.cellF, F.FOV_mean_projection])
    for i = 1:numel(expData)
        dir_list = dir(fullfile(dirs.data,expData(i).sub_dir,'ROI*'));
        expData(i).roi_dir = dir_list.name; %Full path to ROI directory
        expData = get_imgPathnames(dirs,expData,i); %Get pathnames to raw, registered, and matfiles
    end
end