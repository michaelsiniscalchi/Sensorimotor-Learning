%---------------------------------------------------------------------------------------------------
% analyze_smLearning
%
% PURPOSE: To analyze 
%
% AUTHOR: MJ Siniscalchi, 200219
%
% NOTES:
%           *** Scripts for pre-processing movement corrected imaging data ***
%               can be found in: ...\Sensorimotor-Learning\image stack processing
%           * In cases where the whole session is stored in one giant TIFF:
%               -Prior to running 'analyze_smLearning.m', use the script: 'extract_substacks_script.m'
%                   to generate MAT files containing imaging data for each trial. 
%           * If neuropil (background) masks are not generated after cell selection in cellROI.m,
%               use the script get_neuropilMasks_script to generate them post-hoc 
%               (much faster than doing it through the GUI...).
%
%---------------------------------------------------------------------------------------------------

clearvars;

% Set MATLAB path and get experiment-specific parameters
% [dirs, expData] = expData_smLearning(pathlist_smLearning);
[dirs, expData] = expData_smLearning_DEVO(pathlist_smLearning); %For processing/troubleshooting subsets

% Set parameters for analysis
[calculate, summarize, figures, mat_file, params] = params_smLearning(dirs,expData);
expData = get_imgPaths(dirs, expData, calculate, figures); %Append additional paths for imaging data if required by 'calculate'

% Generate directory structure
create_dirs(dirs.results,dirs.summary,dirs.figures);

% Tabulate experimental data for easy reference
expTable = table((1:numel(expData))',{expData.sub_dir}',{expData.criterion}',... %***FUTURE: function expTable = tabulate_expData(expTable,dirs,expData,'') and record more info
    'VariableNames',{'Index','Experiment_ID','Criterion'});

% Begin logging processes
diary(fullfile(dirs.results,['procLog' datestr(datetime,'yymmdd')])); 
diary on;
disp(datetime);

%% ANALYZE BEHAVIOR
if calculate.behavior
    f = waitbar(0);
    for i = 1:numel(expData)
        msg = ['Processing logfile ' num2str(i) '/' num2str(numel(expData)) '...'];
        waitbar(i/numel(expData),f,msg);
        % Parse logfile
        logData = parseLogfile(fullfile(dirs.data,expData(i).sub_dir),expData(i).logfile);
        % Get stimulus, response, and outcome data from each trial
        [sessionData, trialData] = getSessionData(logData);
        % Generate logical masks for specific trial types
        trials = getTrialMasks(trialData);
        %Save processed data
        create_dirs(fileparts(mat_file.behavior(i))); %Create save directory
        save(mat_file.behavior(i),'logData','sessionData','trialData','trials');
    end
    close(f);
    clearvars -except data_dir dirs expData calculate summarize do_plot mat_file params;
end

%% CHECK DATA CONSISTENCY AND INITIALIZE FILE FOR COMBINED IMAGING-BEHAVIOR DATA

% Get image header information generated during acquisition
if calculate.stack_info     %Get header info and tag struct from original TIFs
    for i = 1:numel(expData)
        stackInfo = get_stackInfo(expData(i).raw_path); %Generated during mvt correction or post-hoc with the script 'get_stackInfo.m'
        save(mat_file.stack_info(i),'-STRUCT','stackInfo'); %Save stack info from ScanImage
    end
end

if calculate.combined_data
    % Validation check
    [err_msg,err_data] = check_consistencyImgBeh(dirs,mat_file,expData); %Truncate imaging or behavioral data if necessary and provide info
    save(mat_file.validation,'-STRUCT','err_data'); %Save validation results
    for i = 1:numel(expData)
        %Load behavioral data and imaging info
        behData = load(mat_file.behavior(i),...
            'logData','sessionData','trialData','trials');
        stackInfo = load(mat_file.stack_info(i));
        %Reconcile and save combined data
        data = get_combinedData(behData,stackInfo);
        if ~exist(mat_file.img_beh(i),'file')
            save(mat_file.img_beh(i),'-STRUCT','data'); %Save combined imaging and behavioral data
        else, save(mat_file.img_beh(i),'-STRUCT','data','-append');
        end
    end
end

%% ANALYZE CELLULAR FLUORESCENCE

if calculate.fluorescence
    tic; %Reset timer
    disp(['Processing cellular fluorescence data. ' int2str(numel(expData)) ' sessions total.']);
    f = waitbar(0,'');
    for i = 1:numel(expData)
        %Display waitbar
        msg = ['Session ' num2str(i) '/' num2str(numel(expData)) '...'];
        waitbar(i/numel(expData),f,msg);
        
        % Load behavioral data and metadata from image stacks
        load(mat_file.img_beh(i),'stackInfo','trialData','trials','blocks'); %Load saved data
        
        if calculate.cellF
            %Get cellular and neuropil fluorescence excluding overlapping regions and n-pixel frame
            roi_path = fullfile(dirs.data,expData(i).sub_dir,expData(i).roi_dir);
%             [stack, cells] = get_fluoData(roi_path,expData(i).reg_path,expData(i).mat_path,stackInfo); %Second arg, reg_path set to [] to indicate matfiles already saved.
            [stack, cells] = get_fluoData(roi_path,[],expData(i).mat_path,stackInfo); %Second arg, reg_path set to [] to indicate matfiles already saved.
            [cells, masks] = calc_cellF(stack, cells, params.fluo.exclBorderWidth);
            save(mat_file.cell_fluo(i),'-struct','cells'); %Save to dff.mat
            save(mat_file.cell_fluo(i),'masks','-append'); %Save to dff.mat
            clearvars stack cells masks;
        end
        
        % Calculate dF/F trace for each cell
        if calculate.dFF
            cells = load(mat_file.cell_fluo(i),'cellF','npF','cellID'); %calc_dFF() will transfer any other loaded variables to struct 'dFF'
            cells = calc_dFF(cells, stackInfo, trialData.startTimes,0); %expData(i).npCorrFactor set to zero for prelim analysis
            save(mat_file.img_beh(i),'-struct','cells','-append');
            clearvars cells
        end
        
        % Align dF/F traces to specified behavioral event
        if calculate.align_signals
            cells = load(mat_file.img_beh(i),'dFF','t');
            trialDFF = alignCellFluo(cells,trialData,params.align);
            save(mat_file.img_beh(i),'trialDFF','-append');
            clearvars cells
        end
        
        % Event-related cellular fluorescence
        if calculate.trial_average_dFF %Trial averaged dF/F with bootstrapped CI
            load(mat_file.img_beh(i),'trialDFF','trials','cellID');
            bootAvg = calc_trialAvgFluo(trialDFF, trials, params.bootAvg);
            if ~exist(mat_file.results(i),'file')
                save(mat_file.results(i),'bootAvg','cellID'); %Save
            else, save(mat_file.results(i),'bootAvg','cellID','-append');
            end
        end
               
        % Decode choice, outcome, and rule from single-units
        if calculate.decode_single_units
            load(mat_file.img_beh(i),'trialDFF','trials');
            decode = calc_selectivity(trialDFF,trials,params.decode);
            save(mat_file.results(i),'decode','-append');
        end
        
        %clearvars stackInfo trialData trials blocks roi_path cellF_mat dff_mat
    end
    close(f);
    disp(['Total time needed for cellular fluorescence analyses: ' num2str(toc) 'sec.']); 

end

%% SUMMARY 
% NOTE: To be used as a template for summaries (WILL NOT WORK WITH Sensorimotor Learning Datasets as of 200224)

%***FUTURE: Save reference table

% Behavior
if summarize.behavior
    fieldNames = {'sessionData','trialData','trials','blocks','cellType'};
    B = initSummaryStruct(mat_file.behavior,[],fieldNames,expData); %Initialize data structure
    behavior = summary_behavior(B, params.behavior); %Aggregate results
    save(mat_file.summary.behavior,'-struct','behavior');
end

% Imaging
if summarize.imaging
    fieldNames = {'sessionID','cellID','exclude','blocks','trials','trialDFF'};
    S = initSummaryStruct(mat_file.img_beh,[],fieldNames,expData); %Initialize data structure
    imaging = summary_imaging(S, params.bootAvg); %Aggregate results
    save(mat_file.summary.imaging,'-struct','imaging');
end

% Selectivity
if summarize.selectivity
    %Initialize structure
    for i=1:numel(params.decode.decode_type)
        selectivity.(params.decode.decode_type{i}) = struct();
    end
    %Aggregate results
    for i = 1:numel(expData)
        S = load(mat_file.results(i),'decode','cellID');
        selectivity = summary_selectivity(...
            selectivity, S.decode, expData(i).cellType, i, S.cellID, params.decode); %summary = summary_selectivity( summary, decode, cell_type, exp_ID, cell_ID, params )
    end
    selectivity.t = S.decode.t; %Copy time vector from 'decode'
    save(mat_file.summary.selectivity,'-struct','selectivity');
end

% Summary Statistics and Results Table
if summarize.stats
    %Initialize file
    analysis_name = params.stats.analysis_names;
    if ~exist(mat_file.stats,'file')
        for i = 1:numel(analysis_name)
            stats.(analysis_name{i}) = struct();
        end
        save(mat_file.stats,'-struct','stats');
    end
    
    %Load summary data from each analysis and calculate stats
    stats = load(mat_file.stats);
    for i = 1:numel(analysis_name)
        summary = load(mat_file.summary.(analysis_name{i}));
        stats = summary_stats(stats,summary,analysis_name{i});
    end
    save(mat_file.stats,'-struct','stats');
end

% Stop logging processes
diary off;

%% SUMMARY TABLES
if summarize.table_experiments
    % SessionID, CellType, #Cells, #Trials, #Blocks
    stats = load(mat_file.stats,'behavior','imaging','tables');
    tables.summary = table_expData(expData,stats);
    save(mat_file.stats,'tables','-append');
end

if summarize.table_descriptive_stats
    stats = load(mat_file.stats,'behavior','imaging','selectivity');
    [tables.descriptiveStats, tabular.descriptiveStats] = table_descriptiveStats(stats); %Might not need tabular...
    save(mat_file.stats,'tables','-append');
end

if summarize.table_comparative_stats    
    stats = load(mat_file.stats);
    [tables, tabular] = table_comparisons(stats); %[p,tbl,stats] = kruskalwallis(x,{'SST','VIP','PV','PYR'},displayopt);
    save(mat_file.stats,'tabular','-append');
end

