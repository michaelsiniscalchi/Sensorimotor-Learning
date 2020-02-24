function get_neuropilMasks( roi_dir, subtractmaskRadii )

roiFile = dir(fullfile(roi_dir,'cell*.mat'));

%% For each ROI, get centroid and radius; generate logical mask containing all ROIs

% Initialize variables
S = load(fullfile(roiFile(1).folder,roiFile(1).name),'bw','cellf'); %Get dimensions of FOV from first cellmask, 'bw'
cellmask_all = false(size(S.bw));
subtractmask_all = false(size(S.bw));
centroid = struct('X',cell(numel(roiFile),1),'Y',cell(numel(roiFile),1)); %Initialize
r_ROI = NaN(numel(roiFile),1);

for i = 1:numel(roiFile)
    S = load(fullfile(roiFile(i).folder,roiFile(i).name),'bw'); %s.bw is logical mask for ROI
    [Y,X] = find(S.bw);
    centroid(i).X = mean(X);  %Centroid of ROI
    centroid(i).Y = mean(Y);
    r_ROI(i) = sqrt(sum(S.bw(:))/pi); %Circular ROI with r = sqrt(A/pi) used for estimating neuropil mask
    cellmask_all = cellmask_all | S.bw; %Incorporate ROI into logical mask for all cell bodies
end
clearvars X Y

%% Calculate neuropil fluorescence timeseries
for i = 1:numel(roiFile) 
    
    S = load(fullfile(roiFile(i).folder,roiFile(i).name),'cellf','bw','neuropilf'); %s.bw is logical mask for ROI
    if ~isempty(S.cellf)
        disp(['Generating neuropil mask for cell ' num2str(i) '...']);
    else
        disp(['Cell ' num2str(i) ' excluded. No neuropil mask was saved.']);
        continue
    end
    
    % Construct neuropil mask as annulus with user-defined inside and outside radii
    subtractmask = false(size(cellmask_all));
    circle = cell(2,1); %Cell array for the inner and outer circle
    R = subtractmaskRadii; %Number of cell radii for inner and outer diameter, eg [0,2]
    for j = 1:2
        %Get grids within R(j) cell radii of centroid
        [X,Y] = meshgrid(1:length(subtractmask));
        circle{j} = sqrt((X - centroid(i).X).^2 + (Y - centroid(i).Y).^2)...
            <= R(j) * r_ROI(i);   %Inner or outer radius of annulus in units of cell radius
    end
    subtractmask = circle{2} & ~circle{1} & ~cellmask_all; %Exclude inner circle and somata mask
    subtractmask_all = subtractmask | subtractmask_all; %Incorporate into logical mask for all neuropil
    
    %Save variables in original ROI file
    if ~isfield(S,'neuropilf')
        neuropilf = [];
        save(fullfile(roiFile(i).folder,roiFile(i).name),'neuropilf','-append');
    end
    save(fullfile(roiFile(i).folder,roiFile(i).name),'subtractmask','subtractmaskRadii','-append');
    
    clearvars subtractmask neuropilf
end
disp('Done!');