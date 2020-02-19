%% roc()
%
% PURPOSE: To calculate the empirical receiver operating characteristic.
% AUTHOR: MJ Siniscalchi, 190924
%
% INPUT ARGS:
%       signal: Numeric vector of predictor values (ie, replicates from aligned timeseries data) 
%       class_label: Integer vector of true class labels corresponding to each element of 'signal' 
%       positive_class: Integer specifying the positive class label.
%
% OUTPUTS:
%       tpr: The true positive rate for each threshold value = # True Positive / # Positive
%       fpr: The false positive rate for each threshold value = # False Positive / # Negative
%       auc: The area under the ROC curve, ie, under plot(fpr,tpr)
%--------------------------------------------------------------------------

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
        tpr(i) = sum(class_label==positive_class & signal>=threshold(i))...
            ./sum(class_label==positive_class);
        fpr(i) = sum(class_label~=positive_class & signal>=threshold(i))...
            ./sum(class_label~=positive_class);
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