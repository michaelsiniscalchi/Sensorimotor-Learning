function [ N, P, isTaskCell ] = getTaskCells( trialDFF, trialIdx, window, alpha )

% Time indices for pre/post cue
t = trialDFF.t;
idx.pre = t>=window(1) & t<0; %Aligned timepoints pre-cue
idx.post = t>0 & t<=window(2); %Aligned timepoints post-cue

for i = 1:numel(trialDFF.cueTimes)
    %Abbreviate and include only specified trials
    dff = trialDFF.cueTimes{i}(trialIdx,:); %ie, ~trials.miss for trials completed
    
    %Get mean fluo for 2 s pre and post-cue
    pre.dff = mean(dff(:,idx.pre),2); %Get column vector of mean dFF by trial
    post.dff = mean(dff(:,idx.post),2);
    
    %Test whether dF/F differs pre- vs post-cue
    [~,isTaskCell(i,:)] = signrank(pre.dff,post.dff,'alpha',alpha);    
    
end

% Number and Proportion of Task-Responsive Cells in Population
N = sum(isTaskCell);
P = mean(isTaskCell);


