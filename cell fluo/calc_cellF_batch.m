%%% calcCellF
%
%PURPOSE: To adjust cellF based on two spatial exclusions: 
%       1.) Overlapping regions of multiple ROIs are excluded.
%       2.) An n-pixel width boundary is excluded at the edge of each frame.
%
%AUTHOR: MJ Siniscalchi, 190222
%           -190619mjs Edited to accommodate trial-by-trial movement corrected data...   
%
%INPUT ARGS:    struct 'cells', containing these fields: 
%                   'roimask', a cell array of logical masks, 
%                       each indexing a ROI within the field of view.
%                   'subtractmask', same for the neuropil masks.
%               double 'stack' OR
%               cell   'stack', containing full path to each stack as .MAT
%               double 'borderWidth'
%
%OUTPUTS:       
%               struct roiData, with fields:
%                   cellf:      1d cell array containing final cellular fluorescence for each ROI, post processing
%                   neuropilf:  (same for neuropil fluorescence)
%                   roi:        (same for cell masks)
%                   npMask:     (same for neuropil masks)
%                   
%               struct mask, with fields:
%                   include, exclude: binary arrays containing included/excluded regions 
%
%--------------------------------------------------------------------------

function [cells, masks] = calc_cellF_batch(stack, cells, borderWidth)

if isnumeric(stack) %Data in one stack, input as 3D array
    [nX,nY,nFrames] = size(stack);
    nStacks = 1;
elseif isstruct(stack) %Data in multiple MAT files 
    %Get image info for the series of stacks
    m = matfile(stack.path{1});
    [nX,nY,~] = size(m.stack);
    nStacks = numel(stack.path);
    nFrames = stack.info.nFrames;
else
    error('Argument 1 should be a 3D double array or struct.');
end

%Convert from cell arrays to 3d matrices
cellMasks = cell2mat(cells.roimask);
cellMasks = reshape(cellMasks,[nY,nX,numel(cells.roimask)]);
npMasks = cell2mat(cells.subtractmask);
npMasks = reshape(npMasks,[nY,nX,numel(cells.subtractmask)]);

%Generate inclusion/exclusion masks
masks.include = false(nX,nY); %Initialize
masks.exclude = false(nX,nY);
if nargin > 2 && borderWidth > 0
    masks.exclude([(1:borderWidth) (nY-borderWidth+1:nY)],:) = true; %Frame around image: Top and bottom
    masks.exclude(:,[(1:borderWidth) (nX-borderWidth+1:nX)]) = true; %Left and right
end
masks.exclude(sum(cellMasks,3)>1) = true;     %Overlapping Regions of multiple cells
masks.include(sum(cellMasks,3)==1 & ~masks.exclude) = true; %Logical idx for all ROIs after exclusion

%% Get cellular and neuropil fluorescence, excluding Frame and Overlapping regions
disp(['Getting cellular and neuropil fluorescence, excluding '...
    num2str(borderWidth) '-pixel frame and overlapping regions.']);
cellf =     cell([1 size(cellMasks,3)]); %Pre-allocate memory
neuropilf = cell([1 size(cellMasks,3)]);
roi =       cell([1 size(cellMasks,3)]);
npMask =    cell([1 size(cellMasks,3)]);

%Define spatial masks and preallocate memory
for j = 1:size(cellMasks,3)
    cellf{j} = NaN(sum(nFrames),1); 
    neuropilf{j} = NaN(sum(nFrames),1);
    roi{j} = logical(cellMasks(:,:,j) & ~masks.exclude); %Cell mask from cellROI, excluding specified regions
    npMask{j} = logical(npMasks(:,:,j) & ~masks.exclude); %Neuropil mask from cellROI, excluding specified regions
end

%Get mean fluorescence within each ROI and neuropil mask, for each frame
for i = 1:nStacks
    if nStacks>1
        S = load(stack.path{i},'stack');
        S = S.stack;
    else
        S = stack;
    end
    
    idx = sum(nFrames(1:i))-nFrames(i)+1 : sum(nFrames(1:i)); %startIdx : endIdx
    for j = 1:numel(idx)
        img = S(:,:,j); %single frame
        for k = 1:numel(cellf)
            cellf{k}(idx(j))     = mean(img(roi{k})); %mean pixel value within ROI
            neuropilf{k}(idx(j)) = mean(img(npMask{k})); %same for neuropil mask
        end
    end
    disp(['Frame ' num2str(idx(end)) '/' num2str(sum(nFrames))]);
    clearvars S
end

%Store in structure
cells.cellf = cellf;
cells.neuropilf = neuropilf;
cells.roimask = roi;
cells.neuropilmask = npMask;