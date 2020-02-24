%% tiff2mat()
%
% PURPOSE: To convert movement-corrected TIFF files into 3D arrays stored in MAT format.
%           Returns struct 'info' which contains selected info from ScanImage
%           header as well as the extracted tag struct for writing to TIF.
% AUTHOR: MJ Siniscalchi, 190826
%
%--------------------------------------------------------------------------

function tags = tiff2mat(tif_paths, mat_paths, chan_number)

if nargin<3
   chan_number=[]; %For interleaved 2-color imaging; channel to convert.
end

tic;

w = warning; %get warning state
warning('off','all'); %TROUBLESHOOT: invalid ImageDescription tag from ScanImage

img_info = imfinfo(tif_paths{1}); %Copy info from first raw TIF
img_info = img_info(1);
fields_info = {'Height',      'Width',     'BitsPerSample','SamplesPerPixel'};
fields_tiff = {'ImageLength', 'ImageWidth','BitsPerSample','SamplesPerPixel'};
for i=1:numel(fields_info)
    tags.(fields_tiff{i}) = img_info.(fields_info{i}); %Assign selected fields to tag struct
end
tags.Photometric = Tiff.Photometric.MinIsBlack;
tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tags.Software = 'MATLAB';

for i=1:numel(tif_paths)
    
    [pathname,filename,ext] = fileparts(tif_paths{i});
    source = [filename ext]; %Store filename of source file
    
    disp(['Converting ' source '...']);
    stack = loadtiffseq(pathname,source); % load raw stack (.tif)
    if chan_number %Check for correction based on structural channel
        stack = stack(:,:,chan_number:2:end); %Just convert reference channel
    end
    save(mat_paths{i},'stack','tags','source','-v7.3');
end

%Console display
[pathname,~,~] = fileparts(mat_paths{1});
disp(['Stacks saved as .MAT in ' pathname]);
disp(['Time needed to convert files: ' num2str(toc) ' seconds.']);
warning(w); %revert warning state

