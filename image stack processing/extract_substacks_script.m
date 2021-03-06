%Purpose: To bring all data into processing pipeline, which calculates cellular fluorescence
%           from trial-indexed substacks of imaging data stored in matfiles.
%           Extracts and saves substack for each trial from registered tiff(s)
%
%   ***FUTURE: functionalize and incorporate into processing pipeline,
%           within 'getFluoData.m'. 
%--------------------------------------------------------------------------

clearvars;

% Set MATLAB path and get experiment-specific parameters
% [dirs, expData] = expData_smLearning(pathlist_smLearning);
[dirs, expData] = expData_smLearning_DEVO(pathlist_smLearning); %For processing/troubleshooting subsets

% Set parameters for analysis
[calculate, summarize, figures, mat_file, params] = params_smLearning(dirs,expData);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append additional paths for imaging data if required by 'calculate'

%% Extract all pixel intensity data from TIFFs

for i=1:numel(expData)
    regDir = fullfile(dirs.data,expData(i).sub_dir,'registered');
    regFile = dir(fullfile(regDir,'*.tif'));
    mat_dir = fullfile(fileparts(expData(i).mat_path{1}));
    matlist = dir(fullfile(mat_dir,'*.mat'));
    
    if isempty(matlist) %~isempty(expData(i).reg_path) && isempty(matlist) %Allows exclusion using expData.reg_path
        
        %Create directory for registered matfiles
        create_dirs(mat_dir);
        
        % Get image header information generated during acquisition
        if exist(mat_file.stack_info(i),'file')
            load(fullfile(dirs.data,expData(i).sub_dir,'stack_info'),...
                'nFrames','rawFileName','trigTime','trigDelay');
        else
            stackInfo = get_stackInfo(expData(i).raw_path); %Generated during mvt correction or post-hoc with the script 'get_stackInfo.m'
            save(mat_file.stack_info(i),'-STRUCT','stackInfo'); %Save stack info from ScanImage
        end
        
        if numel(regFile)==1 %Convert data stored in one large registered TIF
            
            %Load imaging data and get tag structure
            regStack = loadtiffseq(regDir,regFile.name);
            tags = get_tagStruct(fullfile(regDir,regFile.name)); %Get tag struct for writing tiffs
            
            %Get frames and assign to trial-indexed substacks
            for j = 1:numel(nFrames)
                if j==1
                    idx = 1:nFrames(1);
                else
                    idx = sum(nFrames(1:j-1))+1 : sum(nFrames(1:j));
                end
                stack = regStack(:,:,idx);
                
                [~,fname,ext] = fileparts(rawFileName{j});
                source = regFile.name;
                
                disp(['Saving ' fullfile(mat_dir,fname) '...']);
                save(fullfile(mat_dir,fname),'stack','tags','source');
            end

        else %Convert registered data stored in one substack per trial
            disp(['Converting ' num2str(numel(expData(i).reg_path)) ' .TIF files to .MAT...']);
            tiff2mat(expData(i).reg_path,expData(i).mat_path);
            disp('Done!')
        end
    end
    clearvars -except i data_dir dirs expData
end