%% calc_ROC()
%
% PURPOSE: To calculate the empirical receiver operating characteristic,
%           with confidence intervals estimated using the bootstrap method.
% AUTHOR: MJ Siniscalchi, 190924
%
% INPUT ARGS:
%       signal: Numeric vector of predictor values (ie, replicates from aligned timeseries data) 
%       class_label: Integer vector of true class labels corresponding to each element of 'signal' 
%       positive_class: Integer specifying the positive class label.
%
% OUTPUTS:
%       TPR: True positive rate for each threshold value = # True Positive / # Positive
%       FPR: False positive rate for each threshold value = # False Positive / # Negative
%       AUC: Area under the ROC curve, ie, under plot(FPR,TPR)
%       bootstrap: Mean AUC with CI estimated with the bootstrap method.
%           Elements are [mean, lower_bound, upper_bound].
%
% NOTES: 
%       -Parallelizing the bootstrap, rather than running this function in a parfor loop with
%           (t = 1:nTime) could improve processing speed. -mjs200219
%---------------------------------------------------------------------------------------------------

function [ TPR, FPR, AUC, bootstrap ] = calc_ROC( signal, class, positive_class, params )

% Calculate empirical receiver operating characteristic
[ TPR, FPR, AUC ] = roc(signal,class,positive_class); %Local function (see bottom)

% Estimate mean and confidence intervals of AUROC using the bootstrap
if nargin>3 && params.nReps>0 %Number of bootstrap replicates    
    
    auc = NaN(params.nReps,1); % Initialize vector of bootstrap replicates
    for i = 1:params.nReps
        %Draw a random sample of trials with replacement
        idx = randsample(size(signal,1),size(signal,1),'true');
        [~,~,auc(i) ] = roc(signal(idx),class(idx),positive_class);
    end
    
    %Estimate grand mean and confidence interval
    bootstrap(1) = nanmean(auc,1); %Mean
    bootstrap(2) = prctile(auc,50-params.CI/2,1); %Lower bound of CI
    bootstrap(3) = prctile(auc,50+params.CI/2,1); %Upper bound of CI
else
    bootstrap = nan(3,1);
end

function [ tpr, fpr, auc ] = roc( signal, class_label, positive_class)

[signal,idx] = sort(signal,'descend'); 
class_label = class_label(idx);

nUnique = numel(unique(signal));
checkUnique =  nUnique==numel(signal); %Check for duplicate values
tpr = NaN(nUnique,1); %True positive rate: TP/P
fpr = NaN(nUnique,1); %False positive rate: FP/N

if checkUnique
    %Vectorized method for speed (~5x faster)
    tpr = cumsum(class_label==positive_class)./sum(class_label==positive_class) ; 
    fpr = cumsum(class_label~=positive_class)./sum(class_label~=positive_class) ; 
    auc = trapz(fpr,tpr); %trapz() should yield exact area, since empirical TPR(FPR) is a step-function
else
    %Loop: use each unique value as a threshold
    threshold = flipud(unique(signal));
    for i=1:numel(threshold)
        tpr(i) = sum(class_label==positive_class & signal>=threshold(i))./sum(class_label==positive_class);
        fpr(i) = sum(class_label~=positive_class & signal>=threshold(i))./sum(class_label~=positive_class);
    end
    auc = trapz(fpr,tpr);
end

% -------NOTES-------
% This should also work:
% thresholds = unique(dff);
% [nTP, ~] = histcounts(dff(class==positive_class),thresholds); %Ascending
% [nFP, ~] = histcounts(dff(class~=positive_class),thresholds);
% tpr = cumsum(fliplr(nTP))./sum(class==positive_class);
% fpr = cumsum(fliplr(nFP))./sum(class~=positive_class);
% auc = trapz(fpr,tpr); %trapz() should yield exact area, since empirical TPR(FPR) is a step-function