%%% calcCellF
%
%PURPOSE: To adjust cellF based on two spatial exclusions: 
%       1.) Overlapping regions of multiple ROIs are excluded.
%       2.) An n-pixel width boundary is excluded at the edge of each frame.
%
%AUTHOR: MJ Siniscalchi, 190222
%
%INPUT ARGS:    struct 'cells', containing these fields: 
%                   'roimask', a cell array of logical masks, 
%                       each indexing a ROI within the field of view.
%                   'subtractmask', same for the neuropil masks.
%               double 'stack'
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

function [cells, masks] = calc_cellF(stack, cells, borderWidth)

%Convert from cell arrays to 3d matrices
[nX,nY,nZ] = size(stack);
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

%Get cellular and neuropil fluorescence, excluding Frame and Overlapping regions
disp(['Getting cellular and neuropil fluorescence, excluding '...
    num2str(borderWidth) '-pixel frame and overlapping regions.']);
cellf =     cell([1 size(cellMasks,3)]); %Pre-allocate memory
neuropilf = cell([1 size(cellMasks,3)]);
roi =       cell([1 size(cellMasks,3)]);
npMask =    cell([1 size(cellMasks,3)]);

for j = 1:size(cellMasks,3)
    disp(['Cell ' num2str(j) '...']);
    roi{j} = logical(cellMasks(:,:,j) & ~masks.exclude); %Cell mask from cellROI, excluding specified regions
    npMask{j} = logical(npMasks(:,:,j) & ~masks.exclude); %Neuropil mask from cellROI, excluding specified regions
    
    %Sum fluorescence within each ROI and neuropil mask, for each frame
    cellf{j} = NaN(nZ,1); 
    neuropilf{j} = NaN(nZ,1);
    for k = 1:nZ
        cellf{j}(k) = sum(sum(stack(:,:,k).*roi{j})); %Pre-2018b sum.m syntax for back-compatibility
        neuropilf{j}(k) = sum(sum(stack(:,:,k).*npMask{j}));
    end
    cellf{j} = cellf{j}/sum(roi{j}(:));   %Mean per-pixel fluorescence
    neuropilf{j} = neuropilf{j}/sum(npMask{j}(:));
end

%Store in structure
cells.cellf = cellf;
cells.neuropilf = neuropilf;
cells.roimask = roi;
cells.neuropilmask = npMask;