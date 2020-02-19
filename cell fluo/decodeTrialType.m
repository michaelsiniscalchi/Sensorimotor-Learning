%INPUT ARGUMENTS:
%   double dFF, a vector of dFF values from a single timepoint from all trials

function [ accuracy, AUC ] = decodeTrialType( dFF, types, classifier_type )

% Exclude trials where dff is NaN
trueTypes = types(~isnan(dFF));
dFF = dFF(~isnan(dFF));

% Initialize variables
C = cvpartition(numel(dFF),'LeaveOut'); %Generate cvpartition object for LOOCV
warning('off','stats:perfcurve:SubSampleWithMissingClasses'); %LOOCV, so classes always missing from each test set
class = zeros(C.NumTestSets,1,'uint8'); %Pre-allocate memory
trueClass = zeros(C.NumTestSets,1,'uint8');
posterior = NaN(C.NumTestSets,numel(unique(types)));

%Classify neural data by trial type, using LOOCV
for i = 1 : C.NumTestSets
    [class(i),~,posterior(i,:)] = classify(...
        dFF(test(C,i)),dFF(training(C,i)),trueTypes(training(C,i)),classifier_type); %class = classify(sample,training,group)
    trueClass(i) = trueTypes(test(C,i)); %Cell array for later call to perfcurve()
end
accuracy = sum(class==trueClass)/numel(class); %Classification accuracy

%Estimate ROC curve and AUC with confidence intervals
%Cell array for labels and scores allows computation of CI for AUC
AUC = NaN(1,3);
if numel(unique(types)) == 2
    [~,~,~,AUC] = perfcurve(num2cell(trueClass),num2cell(posterior(:,1)),1); %posterior((:,1) is posterior probability for class labeled '1'
end

% -------NOTES-------------------------------------------------------------

% % Without cvpartition - not noticeably faster
% % Initialize variables
% class = zeros(numel(trueTypes),1,'uint8'); %Pre-allocate memory
% trueClass = zeros(numel(trueTypes),1,'uint8');
% scores = NaN(numel(trueTypes),numel(unique(types)));
% 
% %Classify neural data by trial type, using LOOCV
% idx = 1:numel(trueTypes);
% for j = idx
%     testIdx = idx==j;
%     trainIdx = ~testIdx;
%     [class(j),~,scores(j,:)] = classify(...
%         dFF(testIdx),dFF(trainIdx),trueTypes(trainIdx),classifier_type); %class = classify(sample,training,group)
%     trueClass(j) = trueTypes(testIdx); %For comparison with classifier output
% end
% accuracy = sum(class==trueClass)/numel(class); %Classification accuracy
