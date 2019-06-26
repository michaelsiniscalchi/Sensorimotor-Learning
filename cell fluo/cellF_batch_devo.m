clearvars;

root = 'C:\Users\Michael\Documents\Data & Analysis\Rule Switching\VIP-Flex-GCaMP\';
roi_dir = fullfile(root,'180927 M57 RuleSwitching','ROI_180927 M57 RuleSwitching.tif');
tiff_dir = fullfile(root,'180927 M57 RuleSwitching','registered');
mat_dir = fullfile(tiff_dir,'MAT');
mkdir(mat_dir);

flist = dir(fullfile(tiff_dir,'*NRMC*'));
for i = 1:numel(flist)
    tiff_path{i} = fullfile(tiff_dir,flist(i).name);
    mat_path{i} = fullfile(mat_dir,flist(i).name(1:end-4));
end

%%

borderWidth = 3;
[stack, cells ] = get_sessionFluoData_batch( roi_dir, tiff_path, mat_path );
[cells, masks] = calc_cellF_batch(stack, cells, borderWidth);