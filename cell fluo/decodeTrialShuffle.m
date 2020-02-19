%INPUT ARGUMENTS:
%   double dFF, a vector of dFF values from a single timepoint from all trials

function  shuffle = decodeTrialShuffle( dFF, types, nShuffle, CI , classifier_type )

% Exclude trials where dff is NaN
trueTypes = types(~isnan(dFF));
dFF = dFF(~isnan(dFF));

% Initialize variables
class = zeros(numel(trueTypes),1,'uint8');
trueClass = zeros(numel(trueTypes),1,'uint8');
shuffle_accuracy = NaN(nShuffle,1); 

% Estimate decoding accuracy on shuffled trial types

for i = 1:nShuffle
    %Classify neural data by shuffled trial type, using LOOCV
    trueTypes = trueTypes(randperm(numel(trueTypes))); %Shuffle trial types
  
    % Without cvpartition()
    idx = 1:numel(trueTypes);
    for j = idx
        testIdx = idx==j;
        trainIdx = ~testIdx;
        class(j) = classify(...
            dFF(testIdx),dFF(trainIdx),trueTypes(trainIdx),classifier_type); %class = classify(sample,training,group)
        trueClass(j) = trueTypes(testIdx); %For comparison with classifier output
    end
    shuffle_accuracy(i) = sum(class==trueClass)/numel(class); %Classification accuracy
    
end

shuffle = [mean(shuffle_accuracy,1),...
    prctile(shuffle_accuracy, 50+CI/2, 1),...
    prctile(shuffle_accuracy, 50-CI/2, 1)];

% ---NOTES---
%
% Tried this in loop; was ~10x slower than looping 'class(j) = classify(...):
%   trueTypes = trueTypes(randperm(numel(trueTypes))); %Shuffle trial types
%   CVmdl = fitcdiscr(dFF,trueTypes,'CrossVal','on','Leaveout','on');
%   shuffle_accuracy(i) = 1-kfoldLoss(CVmdl);
%
% Tried this in loop; was ~3x slower than looping 'class(j) = classify(...):
%     C = cvpartition(numel(dFF),'LeaveOut'); %Generate cvpartition object for LOOCV
%     classf = @(XTRAIN, ytrain,XTEST)(classify(XTEST,XTRAIN,ytrain));
%     shuffle_accuracy(i) = 1 - crossval('mcr',dFF,trueTypes,'predfun',classf,'partition',C);
%
% Tried using cvpartition(); was ~12% slower
%     C = cvpartition(numel(dFF),'LeaveOut'); %Generate cvpartition object for LOOCV
%     for j = 1 : C.NumTestSets 
%         class(j) = classify(...
%             dFF(test(C,j)),dFF(training(C,j)),trueTypes(training(C,j)),classifier_type); %class = classify(sample,training,group)
%         trueClass(j) = trueTypes(test(C,j)); %For comparison with classifier output
%     end
%     shuffle_accuracy(i) = sum(class==trueClass)/C.NumTestSets; %Classification accuracy
