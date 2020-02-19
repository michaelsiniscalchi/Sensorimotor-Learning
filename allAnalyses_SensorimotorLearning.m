%%% allAnalyses_SensorimotorLearning
%
%Purpose: Wrapper for all analyses of sensorimotor learning experiments.
%
%Author: MJ Siniscalchi, 190321
%
%TO DO LIST:
%   -Split trial averaging, multiple linear regression, and ensemble decoding into separate fcns.
%   -Consider: all functions should return vars or objects; save files outside function in script?
%       e.g., [ figs_struct, data_struct ] = start_beh(expData,dirs);
%       Assign all directories at outset of script and save outside of functions. 
%--------------------------------------------------------------------------

clearvars;

%% Set parameters for analysis

% Calculate or re-calculate results
calculate.behavior             = false;
calculate.dFF                  = false;
calculate.cellF                = false; %First get cellf and neuropilf from ROIs, excluding overlapping regions and extremes of the FOV
calculate.trial_average_dFF    = false; %With rudimentary choice preference index: difference/sum of mean traces
calculate.selectivity          = true;  %Linear classifier (LOOCV) and ROC-based choice selectivity index
calculate.mlr_model            = false;
calculate.mlr_nLicks           = false; %Include term for (nlicksright - nlicksleft)
calculate.longitudinal_summary = false;

% Plot results
Plot.mlr_results            = false;
Plot.selectivity_results    = true;
Plot.single_units           = false;
Plot.longitudinal_summary   = false;

% File names for saved data
mat_file.behavior       = 'beh.mat';
mat_file.stackInfo      = 'stackinfo.mat';
mat_file.fluorescence   = 'dff.mat';
mat_file.selectivity    = 'choice_selectivity.mat';
mat_file.regression     = 'mlr_action_outcome.mat';

% Set paths to analysis code
[data_dir,~,~] = smLearning_setPathList;
% Assign data directories and get experiment-spec parameters 
[dirs, expData] = expData_smLearning(fullfile(data_dir,'Sensorimotor Learning'));

%% Set analysis parameters

%***Make func set_Params()
params.exclBorderWidth      = 3;        %For calc_cellF: n-pixel border of FOV to be excluded from analysis 
%params.expIDs              = 1:6;   % Specify experiments, if desired
params.cellIDs              = [];   % Specify cells, if desired; '[]' to include all 
params.trigTimes            = 'cueTimes'; % ***Still needed for calc_mlrActionOutcome
params.window               = (-2:0.5:8);
params.numBootstrapRepeat   = 1000;
params.CI                   = 0.9;
params.minNumTrial          = 0; %plot_psth.m needs to be reworked to accommodate this parameter

% For multiple linear regression
params.subset = {'left','right'}; % Fields from 'trials' structure to include in analysis; eg exclude 'miss'
params.nback = 2;       % Number of prior trials to regress against
params.interaction = true; % Consider interaction terms
params.interdt = 0.01; %For interpolation prior to timeseries alignment
params.regStep = 0.5;   % Duration of non-overlapping time windows
params.pvalThresh = 0.01;   % Alpha for significance test
params.xLabel = 'Time from sound cue (s)';  % XLabel

%***TEMP FOR DEVELOPMENT
% params.calc_Selectivity = false;
% params.expIDs = 1;
%params.numBootstrapRepeat = 100;
%params.cellIDs = 1:10;

expData = expData(end); %Sample data set for code development

%% Analyze behavior
if calculate.behavior
    f = waitbar(0);
    for i = 1:numel(expData)
        msg = ['Processing logfile ' num2str(i) '/' num2str(numel(expData)) '...'];
        waitbar(i/numel(expData),f,msg);
        
        % Parse logfile
        logData = parseLogfile( fullfile(dirs.data,expData(i).sub_dir), expData(i).logfile);
        % Retrieve stimulus, response, and outcome data from each trial
        [sessionData, trialData] = flex_getSessionData(logData);
        % Generate logical masks for specific trial types
        trials = discrim_getTrialMasks(trialData,sessionData.presCodeSet);
        stats = calc_ChoiceStats(trials);
        
        savematpath = fullfile(dirs.analysis,expData(i).sub_dir);
        create_dirs(savematpath);
        save(fullfile(savematpath,mat_file.behavior),...
            'logData','trialData','sessionData','trials','stats');
        
        % Plot raw behavioral data
        % fig = plot_session_beh_vert(trialData,trials,blocks,tlabel,time_range);
        % fig = plot_session_beh_horz(trials,blocks,tlabel);
    end
    close(f);
end

%% Single-cell fluorescence analyses for each experiment
tic;
for i = 1:numel(expData)
    
    disp(['Processing cellular fluorescence data; session ' int2str(i) ' out of ' int2str(numel(expData)) '.']);
    load(fullfile(dirs.analysis,expData(i).sub_dir,'beh.mat'),...
        'sessionData','trialData','trials','stats'); %Load saved behavioral data
    
    % Subdirectories and MAT files to save analysis and figures
    savematpath = fullfile(dirs.analysis,expData(i).sub_dir); %Results directory
    savefigpath = fullfile(savematpath,'figs-fluo');          %Figures directory: cellular fluorescence
    create_dirs(savematpath,savefigpath);
        
    roi_path = fullfile(dirs.data,expData(i).sub_dir,expData(i).roi_dir); %Directory containing all ROIs from current session
    dff_mat = fullfile(savematpath,mat_file.fluorescence);
    stackinfo_mat = fullfile(savematpath,mat_file.stackInfo);
    
    %% Calculate dF/F from ROIs selected in the GUI, cellROI.m

    if ~exist(stackinfo_mat)     %WORK IN PROGRESS
        stackInfo = get_stackInfo();
        save(stackinfo_mat,'-STRUCT','stackInfo'); %Save stack info from ScanImage
    end
    
    if calculate.dFF
        if calculate.cellF
            %Get cellular and neuropil fluorescence excluding overlapping regions and n-pixel frame
            [stack, cells] = get_sessionFluoData(roi_path);
            [cells, masks] = calc_cellF_batch(stack, cells, params.exclBorderWidth);
            save(dff_mat,'-STRUCT','cells'); %Save to dff.mat
            save(dff_mat,'masks','-append'); %Save to dff.mat
            clearvars stack;
        end
        %Calculate dF/F trace for each cell
        stackInfo = load(fullfile(dirs.data,expData(i).sub_dir,mat_file.stackInfo)); %Load stack information from MAT file 
        if ~exist('cells','var') % ie if calcCellF = false
            if exist(dff_mat,'file'), cells = load(dff_mat);
            else [~,cells] = get_sessioFluoData(roi_path); %#ok<SEPEX>
            end
        end
        cells = calc_dFF( stackInfo, cells, trialData.startTimes,...
            sessionData.timeLastEvent, expData(i).npCorrFactor);
        save(dff_mat,'-STRUCT','cells');
        clearvars cells;
    end
    
    % Load behavioral and imaging data for analysis
    cells = load(fullfile(dirs.analysis,expData(i).sub_dir,'dff.mat'),'dFF','t','cellID');
    trigTimes = trialData.(params.trigTimes); %Times for alignment of fluorescence traces
    
    % Trial-averaged dF/F and choice preference (difference-over-sum)
    %***FUTURE EDIT: use interp/align_trials() fcn prior to averaging, for consistency with remainder of analyses
    if calculate.trial_average_dFF
        [bootAvg, choicePref] = calc_trialAvgDFF(trigTimes, trials, cells, params); %Trial averaged dF/F with bootstrapped CI
        save(fullfile(savematpath,mat_file.selectivity),'bootAvg','choicePref');
    end
        
    % ROC-based choice-selectivity index
    if calculate.selectivity
        %***params.calcSel.compTrials, *.trialSubset *.decodeType
        %***Then get rid of labels, trialType1, trialType2, subset...
        %***output struct organized within func
        labels =   {{'left','right','hit','choice'};... %decode choice
                    {'left','right','err','choice'};
                    {'hit','err','left','outcome'};... %decode outcome
                    {'hit','err','right','outcome'}};
                
        for ii = 1:4
            subset = labels{ii}{3};
            trialType1 = trials.(labels{ii}{1}) & trials.(subset);
            trialType2 = trials.(labels{ii}{2}) & trials.(subset);
            type = labels{ii}{4};
            
            [selectivity.(type).(subset), decodePerf.(type).(subset)] =...
                calc_selectivity_ROC(cells, trigTimes, trialType1, trialType2,...
                subset, params);
        end
  
        save(fullfile(savematpath,mat_file.selectivity),...
            'selectivity','decodePerf','-append');
    end
    
    % Multiple linear regression
    if calculate.mlr_model
        [regData, modCells, regParams] = calc_mlrChoiceOutcome(trigTimes, trials, cells, params);
        mat_file.regression = 'mlr_choice_outcome';
        save(fullfile(savematpath,mat_file.regression),'regData','modCells','regParams');
    elseif calculate.mlr_nLicks
        % Include variable for lick direction x magnitude 
        [regData, modCells, regParams] = calc_mlrActionOutcome(trialData, trials, cells, params);
        mat_file.regression = 'mlr_action_outcome';
        save(fullfile(savematpath,mat_file.regression),'regData','modCells','regParams');
    end
    
    %% Plot single-unit results

    if Plot.selectivity_results
        %Load data into workspace
        load(mat_file.selectivity,'bootAvg','choiceSel','decodePerf');
        cellIdx = get_cellIndex(cells,params.cellIDs);
         
        if Plot.single_units
        %Save figure for each cell plotting all combinations of choice x outcome
        figs = plot_trialAvgDFF(cells,trials,trigTimes,bootAvg,params); %arg 'bootAvg' optional, but saves time if pre-calculated; else set to [].
        save_singleUnitPlots(figs,savefigpath); %save as FIG and PNG
        end
                
        % Plot selectivity index with CI for each cell {left_right_hit; left_right_error}
        %figs = plot_selectivityIdx(cells, selectivity, params); 
        %***TROUBLESHOOT
        %-Is idx calculated correctly?
        %-Could be result of LOOCV procedure?? Also some decoding accuracy ~0... should not be possible
        %-Also, Elapsed time is 6719 s for 5 cells * 4 conditions...
        
        % Plot mean decoding accuracy averaged across cells for hits and errors
                
        % Plot selectivity of all cells (from AUROC) as heatmap & same but with insignificant==NaN
        
        %[fig, cellOrder] = plot_selectivity(input,sortParam,tlabel,xtitle,colorRange);
%         savename = fullfile(dirs.analysis,mat_file.selectivity(1:end-4));
%         print(fig,'-dpng',savename);    %Save PNG
%         savefig(fig,savename);    
    toc
    end
    
    if Plot.mlr_results
        if ~exist('regData','var')
            load(fullfile(savematpath,mat_file.regression),'regData','regParams');
        end
        tlabels = {'C(n)','C(n-1)','C(n-2)','R(n)','R(n-1)','R(n-2)',...
                 'C(n)xR(n)','C(n-1)xR(n-1)','C(n-2)xR(n-2)'};
        fig = plot_regr(regData,params.pvalThresh,tlabels,regParams.xLabel);
        print(fig,'-dpng',mat_file.regression(1:end-4));    %png format
        savefig(fig,fullfile(savematpath,mat_file.regression(1:end-4)), 'fig');
    end
    
    clearvars -except data_dir dirs expData params calculate plot mat_file i
end
toc

%% Summarize longitudinal data
if calculate.longitudinal_summary
    cellData = get_longCellData(expData,dirs,mat_file);
    save(fullfile(dirs.summary,'longitudinal_cell_data.mat'),'cellData');
end

if Plot.longitudinal_summary
    fig = plot_longRegrResults(cellData);
    savename = fullfile(dirs.summary,mat_file.regression(1:end-4));
    print(fig,'-dpng',savename);    %Save PNG
    savefig(fig,savename);
    
    fig = plot_cdfChoiceSel(cellData); %***Generate horizontal CI using AUROC analysis
    savename = fullfile(dirs.summary,mat_file.selectivity(1:end-4));
    print(fig,'-dpng',savename);    %Save PNG
    savefig(fig,savename);
    
    %TO DO:
    %Plot selectivity of all cells (from AUROC) as heatmap for each session 
end
