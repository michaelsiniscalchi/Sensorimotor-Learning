%Plot trialData.numRightLick(i) - trialData.numLeftLick(i)

factorAction = NaN(size(trials.left)); %Initialize
nLeft = NaN(size(trials.left));
nRight = NaN(size(trials.left));
for i = 1:numel(trials.left)
    factorAction(i) = trialData.numRightLick(i) - trialData.numLeftLick(i);
    nLeft(i) = trialData.numLeftLick(i);
    nRight(i) = trialData.numRightLick(i);
end

figure;
X = (0:numel(nLeft))';
left = [0; nLeft.*(-trials.left)];
right = [0; nRight.*(trials.right)];
patch(X,left,'r'); hold on
patch(X,right,'b'); hold on
plot(factorAction,'y'); 
%xlim([1 100]);

figure;
plot(factorAction);
