%Apparent synchronization errors 
fname = 'C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning\Learning - imaging\Troubleshooting\180425 M54 Discrim50 177.tif';
header = scim_openTif(fname);
%header.internal.triggerFrameDelayMS: 400.3422 %180425 M54 Discrim50, Trial 177 **matches stackInfo.mat**

% Are max errors associated with max(trigDelay)?
% Answer: in the case of the largest error from 180425, but not in most cases...
flex_setPathList;
data_dir = 'C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning';
[ dirs, expData ] = expData_smLearning(data_dir);

for i = 1:numel(expData)
    % Get stack with maximum delay
    stackInfo = load(fullfile(dirs.data,expData(i).sub_dir,'stackinfo.mat'),'num_frames','trigDelay');
    maxDelay(i) = max(stackInfo.trigDelay);
    maxDelayTrial(i) = find(stackInfo.trigDelay==maxDelay(i));
    % Get trial with greatest frame timing error
    S = load(fullfile(dirs.analysis,expData(i).sub_dir,'dff.mat'));
    maxErrFrame = find(diff(S.cells.t)==max(diff(S.cells.t)));
    maxErrTrial(i) = find(cumsum(stackInfo.num_frames)>maxErrFrame,1,'first');
end