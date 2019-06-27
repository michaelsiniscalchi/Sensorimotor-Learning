%%% allAnalyses_mfcLesion
%
%Purpose: Wrapper for behavior analyses during sensorimotor learning.
%
%Author: MJ Siniscalchi, 190625
%
%TO DO LIST:
%   -nLicks in 500ms pre-cue period to 500ms post ("grace-period")
%--------------------------------------------------------------------------

clearvars;

%% Set parameters

% Set paths to analysis code
[data_dir,~,~] = smLearning_setPathList;
% Assign data directories and get experiment-spec parameters 
[dirs, expData] = expData_bySubject(fullfile(data_dir,'Sensorimotor Learning - MFC Lesion'));

%% Analyze behavior and generate figs
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
        
    % Save processed data
    save_dir = fullfile(dirs.analysis,expData(i).sub_dir);
    savematpath = fullfile(save_dir,expData(i).logfile(1:end-4));
    if ~exist(save_dir,'dir')
        mkdir(save_dir);
    end
    save(savematpath,'logData','trialData','sessionData','trials','stats');
end
close(f);

%% Plot behavioral data
time_range = [-2 5];
for i = 1:numel(expData)
    mat_dir = fullfile(dirs.analysis,expData(i).sub_dir);
    fig_dir = fullfile(mat_dir,'figs');
    create_dirs(fig_dir); %Create dir: 'figs'
    
    %Visualize raw behavioral data
    mat_file = expData(i).logfile(1:end-4); %Load data from .MAT
    S = load(fullfile(mat_dir,mat_file));
    tlabel = [S.sessionData.subject{:},'--',S.sessionData.dateTime{1}];
    fig = plot_behByTrial(S.trialData,S.trials,tlabel,time_range);
    savefig(fig,fullfile(fig_dir,['raw_beh_',mat_file]));
    saveas(fig,fullfile(fig_dir,['raw_beh_',mat_file '.png']));
    
    %Analyse lick statistics and plot
    edges = time_range(1):0.1:time_range(2);
    output = get_lickrate_byTrialType(S.trialData,S.trials,{'hit','err'},edges);
    fig = plot_lickrate_overlay(output);
    savefig(fig,fullfile(fig_dir,['lick_density_',mat_file]));
    saveas(fig,fullfile(fig_dir,['lick_density_',mat_file '.png']));
    
    %Interlick Intervals
    ILIs = get_interLickIntervals(S.trialData);
    fig = plot_interLickIntervals(ILIs);
    savefig(fig,fullfile(fig_dir,['interlick_intervals_',mat_file]));
    saveas(fig,fullfile(fig_dir,['interlick_intervals_',mat_file '.png']));
    
    close all;
end
