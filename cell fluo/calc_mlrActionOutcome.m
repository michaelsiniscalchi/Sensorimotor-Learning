function [ regData, modCells, params_out ] = calc_mlrActionOutcome(trialData, trials, cells, params)
%%% calc_mlrActionOutcome()
%
% PURPOSE:  To analyze cellular fluorescence data from a two-choice sensory
%               discrimination task. Includes numerical variable for choice.
%           
% AUTHORS: MJ Siniscalchi, 190401; based on earlier code by AC Kwan
%
% INPUT ARGS:   
%
%--------------------------------------------------------------------------

% Set parameters, if not specified in argument, 'params'
if nargin<4
    params = struct([]);
end

% Allow specification of subset of params; populate balance with defaults
name_value =  {'window',            (-2:0.5:8);
               'subset',            {'left','right'};
               'nback',             2;
               'interaction',       true;
               'regStep',           0.5;
               'interdt',           0.01;
               'minNumTrial',       5;
               'xLabel',            'Time from sound cue (s)'};   
for i = find(~isfield(params,name_value(:,1)))'
    params(1).(name_value{i,1}) = name_value{i,2}; %If param not present, use default.
end

%Return parameters used in analysis
for i = 1:size(name_value,1)
    params_out.(name_value{i,1}) = params.(name_value{i,1});
end

%% Multiple linear regression  - choice, outcome, and their interaction

% First predictor: Action ~ number of right licks - number of left licks
factorAction = trialData.numRightLick - trialData.numLeftLick;

% Second predictor: Outcome (dummy var)
factorOutcome = false(size(trials.hit)); %Initialize
factorOutcome(trials.hit) = true;  %Dummy code for outcomes during learning: hit or error

% Subset of trials for analysis
trialMask = getAnyMask(trials,params.subset); %eg trials with a response.

% Subset of cells for analysis
if isfield(params,'cellIDs')
    cellList = params.cellIDs;
else
    cellList = 1:numel(cells.dFF);
end

% Get results from linear regression model
trigTimes = trialData.(params.trigTimes);
for j = cellList
    disp(['Conducting multiple linear regression analysis, Cell ' num2str(j)]);
    regData(j) = linear_regr(cells.dFF{j}, cells.t,...
        [factorAction factorOutcome], trigTimes, trialMask, params_out);
end

%% Choice selectivity
factorNames = {'Choice','Outcome','Interaction'};
factorIdx = [2,5,8]; %Column indices for C(n), R(n), and CxR(n) from coeff/pval arrays
timeIdx = regData(1).regr_time > 0;   %Indices associated with time > 0 s from event, eg sound cue
nConsecBins = 3;

nCells = numel(regData); %Initialize
modCells.Choice = false(nCells,1);
modCells.Outcome = false(nCells,1);
modCells.Interaction = false(nCells,1);

%Test each cell for >= N consecutive bins below significance threshold
for j = 1:nCells
    for k = 1:numel(factorNames)
        if testConsecTrue(regData(j).pval(timeIdx,factorIdx(k))<params.pvalThresh, nConsecBins)   %TF = testConsecTrue( logical_vector, nConsec )
            modCells.(factorNames{k})(j)=true;
        end
    end
end