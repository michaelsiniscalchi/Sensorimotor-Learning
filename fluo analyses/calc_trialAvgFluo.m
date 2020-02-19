function bootAvg = calc_trialAvgFluo ( trial_dFF, trials, params )

% Unpack variables from structures
trialSpec = params.trialSpec;
trial_dff = trial_dFF.cueTimes; %***FUTURE, could include arg 'trigger'
time = trial_dFF.t;

% Downsample if specified
if params.dsFactor > 1
    [trial_dff, time] = downsampleTS(trial_dff,time,params.dsFactor);
end

% Calculate trial-averaged dF/F
for i = 1:numel(trial_dff)
    disp(['Calculating trial-averaged dF/F for cell ' num2str(i) '/' num2str(numel(trial_dff))]);  
    for k = 1:numel(trialSpec)
        subset_label = strjoin(trialSpec{k},'_');
        trialMask = getMask(trials,trialSpec{k}); %Logical mask for specified combination of trials
        dff = trial_dff{i}(trialMask,:); %Get subset of trials specified by trialMask
        bootAvg.(subset_label)(i) = getTrialBoot(dff,subset_label,params);
    end   
end
bootAvg.t = time;