function [ trialAvgDFF, choicePref] = calc_trialAvgDFF ( trigTimes, trials, cells, params )

% Set parameters, if not specified in argument, 'params'
if nargin<4
    params = struct([]);
end

% Allow specification of subset of params; populate balance with defaults
name_value = ... 
    {'cellIDs',          1:numel(cells.dFF);
    'window',            (-2:0.5:8);
    'numBootstrapRepeat',1000;
    'CI',                0.9;
    'minNumTrial',       5;
    'xLabel',            'Time from sound cue (s)'};

for ii = find(~isfield(params,name_value(:,1)))'
    params(1).(name_value{ii,1}) = name_value{ii,2}; %If param not present, use default.
end

tic;            %set clock to estimate how long this takes
setup_figprop;  %set up default figure plotting parameters


%% Calculate trial-averaged dF/F & choice selectivity
for i = 1:numel(cells.dFF)
    
    disp(['Calculating trial-averaged dF/F for cell ' cells.cellID{i}]);
    
    trialSpec = {{'left','hit'}; {'right','hit'}; {'left','err'}; {'right','err'}}; %Spec for each trial subset (conjunction of N fields from 'trials' structure.
    for k = 1:numel(trialSpec)
        fieldname = strjoin(trialSpec{k},'_');
        trialMask = getMask(trials,trialSpec{k});
        %***FUTURE: do interp/align_trials() --> 'interdFF', 'interpT' as inputs to get_trialBoot()
        trialAvgDFF.(fieldname)(i) = get_trialBoot( cells.dFF{i}, cells.t, trigTimes(trialMask), fieldname, params);
    end
   
    % Calculate choice selectivity = (A-B)/(A+B)
    choicePref.hit(i) = calc_preference(trialAvgDFF.left_hit(i), trialAvgDFF.right_hit(i));
    choicePref.err(i) = calc_preference(trialAvgDFF.left_err(i), trialAvgDFF.right_err(i));
        
end