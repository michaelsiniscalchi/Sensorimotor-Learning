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
[dirs, expData] = expData_smLearningBeh(fullfile(data_dir,'Sensorimotor Learning - behavior'));

% Imaging dates:
imgDates.M52 = {'4/19/2018'; '4/24/2018'; '4/28/2018'; '5/2/2018'; '5/9/2018'; '5/11/2018';...
                '5/24/2018'; '5/28/2018'; '6/12/2018'};
imgDates.M53 = {'4/16/2018'; '4/18/2018'; '4/23/2018'; '4/28/2018'; '5/1/2018'; '5/4/2018';...
                '5/10/2018'; '5/19/2018'; '5/29/2018'; '6/11/2018'; '6/21/2018'; '10/4/2018';...
                '10/11/2018';'10/18/2018';'10/19/2018'};
imgDates.M54 = {'4/22/2018'; '4/25/2018'; '4/27/2018'; '5/1/2018'; '5/3/2018'; '5/5/2018';...
                '5/15/2018'; '5/25/2018'; '5/30/2018'; '6/8/2018'; '6/15/2018'; '6/19/2018';...
                '10/4/2018'; '10/11/2018'; '10/18/2018'; '10/19/2018'}; %NOTE: exclude 6/8 completely from analysis (rig issues)
imgDates.M55 = {'4/22/2018'; '4/27/2018'; '5/2/2018'; '5/5/2018'; '5/12/2018'; '5/18/2018';...
                '6/11/2018'; '6/15/2018'; '10/4/2018'; '10/11/2018'; '10/18/2018'};
imgDates.M56 = {'4/26/2018'; '4/27/2018'; '5/4/2018'; '5/9/2018'; '5/17/2018'; '5/30/2018';...
                '6/13/2018'; '10/5/2018'; '10/11/2018'; '10/18/2018'; '10/19/2018'};

%% Analyse behavior and generate figs
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
    
    % Plot raw behavioral data
    % fig = plot_session_beh_vert(trialData,trials,blocks,tlabel,time_range);
    % fig = plot_session_beh_horz(trials,blocks,tlabel);
end
close(f);

%% Collect behavioral stats by subject and save in MAT file
dir_list = unique({expData(:).sub_dir});

for i = 1:numel(dir_list)
    file_list = dir(fullfile(dirs.analysis,dir_list{i},'*.mat'));
    for j = 1:numel(file_list)
        load(fullfile(dirs.analysis,dir_list{i},file_list(j).name),'sessionData','stats');
        S.(dir_list{i}).date{j} = sessionData.dateTime{1};
        S.(dir_list{i}).correctRate(j) = stats.correctRate;
        S.(dir_list{i}).dprime(j) = stats.dprime;
    end
end
nSubjects = numel(fieldnames(S));

for i = 1:nSubjects
    fig = figure;
    
    %Plot performance for all sessions
    [dateNums,idx] = sort(datenum(S.(dir_list{i}).date(:)));
    X = dateNums-dateNums(1); %Time in days starting at first session.
    Y = S.(dir_list{i}).correctRate(idx)';
    plot(X,Y,'k.','LineStyle','none'); hold on;
    
    %Plot trend line
    Y2 = smoothdata(Y,'movmedian',5);
    plot(X,Y2,'k-','LineWidth',2);
    %Plot line for each perf. criterion
    for criterion = 0.55:0.1:0.85
        plot(X,ones(numel(X),1) * criterion,'k:');
    end
    
    %Circle sessions with imaging 
    imgDate_nums = dateNums(ismember(dateNums,datenum(imgDates.(dir_list{i}))));
    imgDate_str = imgDates.(dir_list{i})(ismember(imgDate_nums,dateNums));
    X3 = imgDate_nums - dateNums(1); %Time in days starting at first session.
    Y3 = Y(ismember(dateNums,imgDate_nums));
    
    plot(X3,Y3,'bo','MarkerSize',10,'LineStyle','none');
    for j=1:numel(Y3)
        text(X3(j),Y3(j),imgDate_str(j));
    end
    
    title([dir_list{i} ': Performance across training sessions']);
    xlabel('Training days');
    ylabel('Correct rate (%)');
    ylim([0.3 1]);
       
    savefig(fig,fullfile(dirs.analysis,[dir_list{i} '_plot_smoothed_perf']));
end

