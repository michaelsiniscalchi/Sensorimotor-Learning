clearvars;

%User selects next image stack (session) from longitudinal imaging
root_dir = 'C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning\Learning - imaging';
[filename, pathname] = uigetfile(fullfile(root_dir,'*.tif')); 

target_dir = fullfile(pathname,['ROI_' filename]);
if ~exist(target_dir,'dir')
    mkdir(target_dir);
end

roiData = getMasterROIs(root_dir);
transferRois(roiData,target_dir);

function transferRois(roiData,target_dir)

cell_IDs = unique(roiData.cell_ID);
used_IDs = false(1,max(str2double(cell_IDs')));
for i = 1:numel(roiData.cell_ID)
    idx = str2double(roiData.cell_ID{i});
    save_name = strcat('cell',sprintf('%03d',idx),'.mat');
    if ~ismember(idx,find(used_IDs)) && ~exist(fullfile(target_dir,save_name),'file')
        S = struct('cellf',[],'bw',roiData.bw{i});
        save(fullfile(target_dir,save_name),'-struct','S');
        used_IDs(idx) = true;
    end
end
end

