%INPUT ARGUMENTS:
%   double dFF, a vector of dFF values from a single timepoint from all trials

function [ AUC, accuracy ] = calc_ROC( dFF, trialtype1, trialtype2 )

%Include dFF only from trials of the specified types 
subset = trialtype1 | trialtype2; %Subset spans sample space
trueTypes = trialtype1(subset); %Type within subset, relative to trialtype1
dFF = dFF(subset);

%Exclude any NaN values
%***align_signal() always excludes first trial...fix!
trueTypes = trueTypes(~isnan(dFF)); %Exclude trials where dff is NaN
dFF = dFF(~isnan(dFF));

%Classify neural data by trial type, using LOOCV
C = cvpartition(numel(dFF),'LeaveOut'); %Generate cvpartition object for LOOCV
warning('off','stats:perfcurve:SubSampleWithMissingClasses'); %LOOCV, so classes always missing from each test set
for i = 1 : C.NumTestSets
    [class(i),~,scores(i,:)] = classify(...
        dFF(test(C,i)),dFF(training(C,i)),trueTypes(training(C,i))); %class = classify(sample,training,group)
    trueClass(i) = trueTypes(test(C,i)); %Cell array for later call to perfcurve()
end
accuracy = sum(class==trueClass)/numel(class); %Classification accuracy

%Estimate ROC curve and AUC with confidence intervals
%Cell array for labels and scores allows computation of CI for AUC
[~,~,~,AUC] = perfcurve(num2cell(trueClass),num2cell(scores(:,2)),1); %posterior((:,2) is posterior probability for class labeled '1'
