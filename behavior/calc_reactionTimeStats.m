function RT = calc_reactionTimeStats( trialData, trials, blocks, params )

%% Detrend reaction times to account for gradual change over session
rt = trialData.reactionTimes*1000; %Reaction time in ms
[~,~,RT.deTrended,~] = detrend_RT( rt, blocks, params.pThresh);

%% Multiple linear regression

% Predictor specification
P.choice = trials.left;
%P.priorChoice = trials.priorLeft;
%P.outcome = trials.hit; 
P.priorOutcome = trials.priorHit;
%P.rule = trials.sound;
P.trialIdx = (1:numel(trials.hit))';

% fields = fieldnames(P);
% P = rmfield(P,fields(~ismember(fields,params.COR.predictors)));

%Trial subset
subset = false(numel(trialData.reactionTimes),1);
subset(trials.(params.COR.subset)) = true; 

%Last trial
lastTrial = blocks.firstTrial(end)-1; %Only include trials through the penultimate block

[ RT.stats, RT.outliers ] = regress_RT(rt, lastTrial, subset, P);
