function B = catSwitchPerf( B, trials, blocks, expIdx )

%Note: Window duration fixed based on minimum block length. 
%   If greater #trials desired post-switch, must modify struct blocks to exclude subset,
%   or use specialized coding for outcomes past firstTrial(i)+nTrials(i)

%Exclude last block if session aborted early
window = [-20 20]; %Window fixed based on minimum block length
nBlocks = numel(blocks.nTrials(blocks.nTrials>=window(2))); %Number of blocks

%Initialize data struct
rule = {'sound','action','all'};
outcome = {'hit','pErr','oErr','miss'};

for i = 1:numel(outcome)
    for j = 1:numel(rule)
        perf.(outcome{i}).(rule{j}) = NaN(nBlocks-1,diff(window)); %Performance array: size(nSwitches,nSwitchTrials)
    end
end

%Populate each row of outcome arrays with logical idxs for corresponding trials
blocks.type(ismember(blocks.type,{'actionL','actionR'})) = {'action'};
for i = 1:numel(outcome)
    for j = 1:nBlocks-1
        trialIdx = blocks.firstTrial(j+1)+window(1):blocks.firstTrial(j+1)+window(2)-1;
        perf.(outcome{i}).all(j,:) = trials.(outcome{i})(trialIdx);
        perf.(outcome{i}).(blocks.type{j+1})(j,:) = trials.(outcome{i})(trialIdx); %Referenced by next block, eg A->S found in field 'sound'
    end
end

% Outcome density for each trial relative to switch
cellType = fieldnames(expIdx);
for i =1:numel(cellType)
    for j = 1:numel(outcome)
        for k = 1:numel(rule)
            B.(cellType{i}).perfCurve.(outcome{j}).(rule{k})(expIdx.(cellType{i}),:) = ...
                nanmean(perf.(outcome{j}).(rule{k})); %Performance array: size(nSwitches,nSwitchTrials)
        end
    end
end