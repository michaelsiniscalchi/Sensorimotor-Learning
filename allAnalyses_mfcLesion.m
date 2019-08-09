%%% allAnalyses_mfcLesion
%
%Purpose: Wrapper for behavior analyses during sensorimotor learning.
%
%Author: MJ Siniscalchi, 190625
%
%TO DO LIST:
%   -nLicks in 500ms pre-cue period to 500ms post ("grace-period")
%--------------------------------------------------------------------------

%% Set Hyperparameters

clearvars;

% For processing behavioral data
proc.individual_sessions = true;
proc.longitudinal_data = true;
proc.group_comparisons = false;

% For figures
plots.individual_sessions = false;
plots.longitudinal_data = true;
plots.group_comparisons = false;
plots.time_range = [-2 5];

% Paths to analysis code
[data_dir,~,~] = smLearning_setPathList;

% Assign data directories and get experiment-spec parameters
[dirs, expData] = expData_bySubject(fullfile(data_dir,'Sensorimotor Learning - MFC Lesion'));
%expData = getTestCond(); %lesion or control
sessionIdx = 1:numel(expData); %**DEVO %12

mat_dir  = @(exper_idx) fullfile(dirs.analysis,expData(exper_idx).sub_dir); %proc data dir
fig_dir  = @(exper_idx) fullfile(mat_dir(exper_idx),'figs'); %figs dir
mat_file = @(exper_idx) expData(exper_idx).logfile(1:end-4); %proc data filename

%% Analyze individual sessions
if proc.individual_sessions
    f = waitbar(0);
    for i = sessionIdx 
        msg = ['Processing logfile ' num2str(i) '/' num2str(numel(expData)) '...'];
        waitbar(i/numel(expData),f,msg);
        
        % Parse logfile
        logData = parseLogfile( fullfile(dirs.data,expData(i).sub_dir), expData(i).logfile);
        % Retrieve stimulus, response, and outcome data from each trial
        [sessionData, trialData] = flex_getSessionData(logData);
        % Generate logical masks for specific trial types
        trials = discrim_getTrialMasks(trialData);
        % Calculate choice and lick density stats 
        stats = calc_choiceStats(trials);
        stats = calc_lickStats(trialData,trials,stats);
        
        % Save processed data
        if ~exist(mat_dir(i),'dir')
            mkdir(mat_dir(i));
        end
        save(fullfile(mat_dir(i),mat_file(i)),...
            'logData','trialData','sessionData','trials','stats');
    end
    close(f);
    clearvars -except proc plots expData dirs mat_dir mat_file fig_dir sessionIdx
end

% Figures
if plots.individual_sessions
    for i = sessionIdx 
        create_dirs(fig_dir(i)); %Create dir: 'figs'
        
        %Visualize raw behavioral data
        S = load(fullfile(mat_dir(i),mat_file(i)));
        tlabel = [S.sessionData.subject{:},'--',S.sessionData.dateTime{1}];
        fig = plot_behByTrial(S.trialData, S.trials, tlabel, plots.time_range);
        savefig(fig, fullfile(fig_dir(i),['raw_beh_',mat_file(i)]));
        saveas(fig, fullfile(fig_dir(i),['raw_beh_',mat_file(i) '.png']));
        
        %Analyse lick statistics and plot
        edges = plots.time_range(1):0.1:plots.time_range(2);
        output = get_lickrate_byTrialType(S.trialData,S.trials,{'hit','err'},edges);
        fig = plot_lickrate_overlay(output);
        savefig(fig,fullfile(fig_dir(i),['lick_density_',mat_file(i)]));
        saveas(fig,fullfile(fig_dir(i),['lick_density_',mat_file(i) '.png']));
        
        %Interlick Intervals
        ILIs = get_interLickIntervals(S.trialData);
        fig = plot_interLickIntervals(ILIs);
        savefig(fig,fullfile(fig_dir(i),['interlick_intervals_',mat_file(i)]));
        saveas(fig,fullfile(fig_dir(i),['interlick_intervals_',mat_file(i) '.png']));
        
        close all;
    end
    clearvars -except proc plots expData dirs mat_dir mat_file fig_dir sessionIdx
end

%% Summary Analyses
% -Plot for each subject: hit rate, d-prime, lick stats as fcn of nSessions (try by nTrials performed as well)...
% -Lick stats, eg pre-cue lick rate and pre/post cue lick rate...
% -Stat related to alternation outside of reward period, eg P(nextlick_contra|lick_ipsi)??
% -Consistency of reaction and response
% -Reaction time and/or dispersion... look like RTs get more consistent over training.
%
% -Group stats after unblinding...

%% Collect behavioral stats by subject and save in MAT file
if proc.longitudinal_data
    dir_list = unique({expData(:).sub_dir});
    for i = 1:numel(dir_list)
        file_list = dir(fullfile(dirs.analysis,dir_list{i},'*.mat'));
        for j = 1:numel(file_list)
            
            S = load(fullfile(dirs.analysis,dir_list{i},file_list(j).name),'sessionData','stats');
            if S.sessionData.gracePeriodDur==0, continue; end %**Devo; later, just screen the data
            
            fields = fieldnames(S.stats);
            for k = 1:numel(fields)
                statsBySubj.(dir_list{i}).(fields{k})(j) = S.stats.(fields{k});
            end
            statsBySubj.(dir_list{i}).date{j} = S.sessionData.dateTime{1};
        end
    end
    save(fullfile(dirs.summary,'summary_stats'),'-struct','statsBySubj');
    clearvars -except proc plots expData dirs mat_dir mat_file fig_dir
end

if plots.longitudinal_data
    stats = load(fullfile(dirs.summary,'summary_stats'));
    figs = plot_longPerf(stats);
    for i=1:numel(figs)
        savefig(figs(i),fullfile(dirs.summary,figs(i).Name));
        saveas(figs(i),fullfile(dirs.summary,[figs(i).Name,'.png']));
    end
    clearvars -except proc plots expData dirs mat_dir mat_file fig_dir
end


