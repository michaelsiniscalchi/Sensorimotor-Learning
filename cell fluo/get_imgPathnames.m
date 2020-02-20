%%% get_imgPathnames()
%
% AUTHOR: MJ Siniscalchi,190823
%
%--------------------------------------------------------------------------

function expData = get_imgPathnames(dirs,expData,idx)

% Get paths to raw and registered imaging data, and define path for matfiles
raw_dir = fullfile(dirs.data,expData(idx).sub_dir,'raw');
reg_dir = fullfile(dirs.data,expData(idx).sub_dir,'registered');
mat_dir = fullfile(dirs.data,expData(idx).sub_dir,'mat');
stackInfo = fullfile(dirs.data,expData(idx).sub_dir,'stack_info.mat');

%Location of raw data or stack info
if exist(stackInfo,'file')
    load(stackInfo,'rawFileName');
else
    flist = dir(fullfile(raw_dir,'*.tif'));
    [~,I] = sort([flist.datenum]); %Sort by datenum: sorting by filename fails if insufficient leading zeros 
    rawFileName = {flist(I).name}';
end

for i = 1:numel(rawFileName)
    expData(idx).raw_path{i} = fullfile(raw_dir,rawFileName{i});
    [~,fname] = fileparts(rawFileName{i});    %Assign filename from raw TIF
    expData(idx).mat_path{i} = fullfile(mat_dir,[fname '.mat']); 
end

%Get paths to registered substacks
flist = dir(fullfile(reg_dir,'*.tif')); %Tiffs registered using iCorre_batch.m have sufficient leading zeros, so no need to sort
if ~isempty(flist) && numel(flist)>1 %***Temporarily keep " && numel(flist)>1" to exclude stitched sessions...
    for i=1:numel(flist)
        expData(idx).reg_path{i} = fullfile(reg_dir,flist(i).name);
    end
else %If 'registered' dir is empty, absent, or contains one giant TIFF 
    expData(idx).reg_path = []; %Note: if data registered as one big tiff, split by trial, eg using 'extract_substacks_script.m' to conform with processing pipeline
end

%All Column vectors
expData(idx).raw_path = expData(idx).raw_path(:);
expData(idx).reg_path = expData(idx).reg_path(:);
expData(idx).mat_path = expData(idx).mat_path(:);
