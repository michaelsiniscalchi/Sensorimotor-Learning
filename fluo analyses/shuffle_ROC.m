%% shuffle_ROC()
%
% PURPOSE: To calculate the empirical receiver operating characteristic.
% AUTHOR: MJ Siniscalchi, 190924
%
% INPUT ARGS:
%       signal: Numeric vector of predictor values (ie, replicates from aligned timeseries data) 
%       class_label: Integer vector of true class labels corresponding to each element of 'signal' 
%       positive_class: Integer specifying the positive class label.
%       params.nShuffle: Number of shuffled replicates
%
% OUTPUTS:
%       AUC: The area under the ROC curve, ie under plot(fpr,tpr), for each
%           shuffled replicate of the data.
%--------------------------------------------------------------------------

function [ TPR, FPR, AUC ] = shuffle_ROC( signal, class, positive_class, nShuffle )

% Fixed Parameters
positive_class = 1;

% Initialize
nTime = size(signal,2);
nCrit = size(signal,1); %Each unique value is used as a threshold in roc()
AUC = NaN(nShuffle,nTime); %Area under the ROC curve
TPR = NaN(nShuffle,nCrit,nTime); %True positive rate; prior to output, results are averaged over all shuffles
FPR = NaN(nShuffle,nCrit,nTime); %False positive rate

% Estimate Receiver Operating Characteristic (ROC) for each shuffle of class labels
parfor i = 1:nShuffle
   
%     tpr = NaN(nCrit,nShuffle);
%     fpr = NaN(nCrit,nShuffle);
    
    
    
    %Shuffle class labels
    shuffled_labels = class(randperm(numel(class)));
    
    %Calculate receiver operating characteristic for each timepoint 
    for t = 1:nTime
        [TPR(i,:,t),FPR(i,:,t),AUC(i,t)] = roc(signal(:,t),shuffled_labels,positive_class);
    end
    %Aggregate 
%     TPR
%     FPR
end
TPR = squeeze(mean(TPR,1));
FPR = squeeze(mean(FPR,1));
