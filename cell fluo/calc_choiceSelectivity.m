function [ trialAvgDFF, choiceSel] = calc_choiceSelectivity( trigTimes, trials, cells, params )

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

for j = params.cellIDs
    
    disp(['Calculating trial-averaged dF/F for cell ' num2str(j)]);
    
    trialSpec = {{'left','hit'}; {'right','hit'}; {'left','err'}; {'right','err'}}; %Spec for each trial subset (conjunction of N fields from 'trials' structure.
    for k = 1:numel(trialSpec)
        fieldname = strjoin(trialSpec{k},'_');
        trialMask = getMask(trials,trialSpec{k});
        trialAvgDFF.(fieldname)(j) = get_psth( cells.dFF{j}, cells.t, trigTimes(trialMask), fieldname, params);
    end
   
    % Calculate choice selectivity = (A-B)/(A+B)
    choiceSel.hit(j) = calc_selectivity(trialAvgDFF.left_hit(j), trialAvgDFF.right_hit(j));
    choiceSel.err(j) = calc_selectivity(trialAvgDFF.left_err(j), trialAvgDFF.right_err(j));
        
end