function meanProj = calc_meanProj( mat_path )

%Typically one matfile per trial, derived from motion-corrected TIFFs using 'tiff2mat.m'

% Aggregate all frames from imaging data stored in MAT files
% frames = cell(numel(mat_path),1); 
frames = cell(10,1); 
for j = 1:numel(mat_path)
    disp(['Loading ' mat_path{j} '...']);
    S = load(mat_path{j});
    frames{j} = shiftdim(S.stack,2);
end

%Concatenate trials
M = cell2mat(frames);
meanProj = squeeze(mean(M,1));