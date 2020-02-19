function lickDensity = getLickDensity( trialData, trials, edges )

%Fixed Conditions
subset = 'last20';

%% Lick density, organized heirarchically by Choice, Cue and Rule
cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};
binWidth = diff(edges(1:2));
for i = 1:numel(cue)
    for j = 1:numel(rule)
        %Extract specified data
        trialIdx = getMask(trials,{cue{i},rule{j},subset});
        unit = sum(trialIdx)*binWidth; %nTrials*seconds/bin
        lickDensity.left.(cue{i}).(rule{j}) = ...
            histcounts([trialData.lickTimesLeft{trialIdx}],edges)/unit; %Counts/trial/second
        lickDensity.right.(cue{i}).(rule{j}) = ...
            histcounts([trialData.lickTimesRight{trialIdx}],edges)/unit;
    end
end
lickDensity.t = edges(1:end-1) + 0.5*binWidth; %Assign to center of time 