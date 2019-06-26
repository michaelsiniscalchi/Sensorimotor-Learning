%%% allBehavior_SensorimotorLearning
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

%% Set parameters

% Set paths to analysis code
[data_dir,~,~] = smLearning_setPathList;
% Assign data directories and get experiment-spec parameters 
[dirs, expData] = expData_smLearningBeh(fullfile(data_dir,'Sensorimotor Learning - MFC Lesion'));

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
    if sessionData.nTrials < 100
        warning('Session has < 100 trials. Check!');
        disp(['Filename: ' expData(i).logfile(1:end-4)]);
    end
    savematpath = fullfile(dirs.analysis,expData(i).sub_dir);
    if ~exist(savematpath,'dir')
        mkdir(savematpath);
    end
    save(fullfile(savematpath,expData(i).logfile(1:end-4)),...
        'logData','trialData','sessionData','trials','stats');
end
close(f);

    % Plot raw behavioral data
    fig = plot_session_beh_vert(trialData,trials,blocks,tlabel,time_range);
    % fig = plot_session_beh_horz(trials,blocks,tlabel);