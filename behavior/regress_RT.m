%%% regress_RT()
%
% PURPOSE: To regress out linear time-varying component of reaction time for comparisons
%       across rule blocks.
%
% AUTHOR: MJ Siniscalchi, 191030
%
%---------------------------------------------------------------------------------------------------

function [ stats, outliers ] = regress_RT( RT, nTrials, subset, predictors )

%Initialize
X = nan(nTrials,numel(predictors)); %Predictor matrix, dim nTrials x nPredictors; constant term added by regstats()
y = RT(1:nTrials); 

%Populate matrix X with input predictors
pred_names = fieldnames(predictors);
for i = 1:numel(pred_names)
    X(:,i) = predictors.(pred_names{i})(1:nTrials);
end

%Operate only on specified subset of trials
subset = subset(1:nTrials); %Truncate to nTrials, eg last trial before last block
X = X(subset,:);
y = y(subset);

%Find and remove outliers
[~,~,~,rint] = regress(y,X); %Residual is larger than P new predictions where proportion P = (1-alpha)   
outliers = rint(:,1)>0 | rint(:,2)<0;
y(outliers) = NaN;

%Regress remaining values against trial index
regStats = regstats(y,X,'linear',{'rsquare','fstat','tstat','yhat'});

%Assign regression coefficients
statNames = {'rsquare','fstat','yhat'};
for i = 1:numel(statNames)
stats.(statNames{i}) = regStats.(statNames{i});
end

%Individual coefficient tests
stats.beta.constant = regStats.tstat.beta(1);
stats.pval.constant = regStats.tstat.pval(1);
for j = 1:numel(pred_names)
stats.beta.(pred_names{j}) = regStats.tstat.beta(j+1);
stats.pval.(pred_names{j}) = regStats.tstat.pval(j+1);
end