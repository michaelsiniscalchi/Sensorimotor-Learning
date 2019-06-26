function [ reg_cr, modCells, params ] = calc_mlrChoiceOutcome(trialData, trials, cells, params)
%%% calc_mlrChoiceOutcome()
%
% PURPOSE:  To analyze cellular fluorescence data from a two-choice sensory
%               discrimination task.
%           
% AUTHORS: MJ Siniscalchi, 190401
%
% INPUT ARGS:   
%
%--------------------------------------------------------------------------

% Set parameters, if not specified in argument, 'params'
if nargin<3
    params = struct([]);
end

% Allow specification of subset of params; populate balance with defaults
name_value =  {'expList',           1:numel(expData);
               'trigTime',          'cueTimes'; 
               'window',            (-2:0.5:8);
               'numBootstrapRepeat',1000; 
               'CI',                0.9;                 
               'predictors',        {'left','hit'}; 
               'subset',            {'left','right'};
               'nback',             2;
               'interaction',       true;
               'regStep',           0.5;
               'interdt',           0.01;
               'minNumTrial',       5;
               'xLabel',            'Time from sound cue (s)'};   
for ii = find(~isfield(params,name_value(:,1)))'
    params(1).(name_value{ii,1}) = name_value{ii,2}; %If param not present, use default.
end

tic;            %set clock to estimate how long this takes
setup_figprop;  %set up default figure plotting parameters

    %% CHOICE AND OUTCOME: Multiple linear regression  - choice, reward, and their interaction
    
    % First predictor: choice (dummy var)
    factorChoice = NaN(size(trials.left)); %Misses remain = NaN
    factorChoice(trials.left) = 1; %Dummy codes for choices - arbitrary
    factorChoice(trials.right) = 0;
    % Second predictor: outcome (dummy var)
    factorOutcome=NaN(size(trials.hit)); %Misses remain = NaN
    factorOutcome(trials.hit) = 1;  %Dummy codes for outcomes during learning: hit or error
    factorOutcome(trials.err) = 0;  
        
    if isfield(params,'cellIDs')
        cellList = params.cellIDs{i};
    else
        cellList = 1:numel(cells.dFF);
    end
    
    trigTime = trialData.(params.trigTime);
    trialMask = getAnyMask(trials,params.subset); %only perform analysis on subset of trials, eg those with a response.
    for j = cellList 
        disp(['Conducting multiple linear regression analysis, Cell ' num2str(j)]);
        reg_cr(j) = linear_regr(cells.dFF{j}, cells.t,...
            [factorChoice factorOutcome], trigTime, trialMask, params);
    end
    
    tlabel={'C(n)','C(n-1)','C(n-2)','R(n)','R(n-1)','R(n-2)',...
        'C(n)xR(n)','C(n-1)xR(n-1)','C(n-2)xR(n-2)'};
    
    plot_regr(reg_cr,params.pvalThresh,tlabel,params.xLabel);
    print(gcf,'-dpng','MLR-choiceoutcome');    %png format
    saveas(gcf, 'MLR-choiceoutcome', 'fig');
    
    save(fullfile(savematpath,'dff_and_beh.mat'),'reg_cr','params','-append');
    
    %% Which cells are choice selective?
    factorNames = {'Choice','Outcome','Interaction'};
    factorIdx = [2,5,8]; %C(n), R(n), CxR(n)
    timeIdx = find(reg_cr(1).regr_time>0,1,'first');   %find index associated with time > 0 s from event, eg sound cue
    nConsecBins = 3;
    
    nCells = numel(reg_cr); %Initialize
    modCells.Choice = false(nCells,1);
    modCells.Outcome = false(nCells,1);
    modCells.Interaction = false(nCells,1);

    for j = 1:nCells
        for k = 1:numel(factorNames)
            if testConsecTrue(reg_cr(j).pval(timeIdx:end,factorIdx(k))<params.pvalThresh,nConsecBins)   %TF = testConsecTrue( logical_vector, nConsec )
                modCells.(factorNames{k})(j)=true;
            end
        end
    end
    save(fullfile(savematpath,'dff_and_beh.mat'),'modCells','-append');
    
    clearvars -except i dirs expData params;
    %close all;
end