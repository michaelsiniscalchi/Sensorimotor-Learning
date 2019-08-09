function ILIs = get_interLickIntervals(trialData)

%DEVO
% clearvars;
% load('C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning - MFC Lesion\analysis\M62\M62_DISCRIM_1905211245.mat');

%%
lickTimes_L = trialData.lickTimesLeft(:); %Column vectors
lickTimes_R = trialData.lickTimesRight(:);

%Aggregate all licktimes from right and left ports
lickTimes_all = cell(numel(lickTimes_L),1);
for i = 1:numel(lickTimes_L)
    lickTimes_all{i} = sort([lickTimes_L{i},lickTimes_R{i}]);
end

%Calculate ILIs = difference between consecutive lick times  
ILIs.all = cellfun(@diff,lickTimes_all,'UniformOutput',false);
ILIs.left = cellfun(@diff,lickTimes_L,'UniformOutput',false);
ILIs.right = cellfun(@diff,lickTimes_R,'UniformOutput',false);

%Bouts are separated by > 0.5 seconds
thresh = @(v) v(v<0.5);
ILIs.allBouts = cellfun(thresh,ILIs.all,'UniformOutput',false);
ILIs.leftBouts = cellfun(thresh,ILIs.left,'UniformOutput',false);
ILIs.rightBouts = cellfun(thresh,ILIs.right,'UniformOutput',false);