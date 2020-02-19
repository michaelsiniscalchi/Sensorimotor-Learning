function B = catLickRates( B, lickRates, lickDiffs, expIdx )

cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
pre_post = {'preCue','postCue'};

% Lick Rates
for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    for j = 1:numel(pre_post)
        fields = fieldnames(lickRates.(pre_post{j}));
        for k = 1:numel(fields)
             B.(cellType{i}).lickRates.(pre_post{j}).(fields{k})(idx,:) = ... %Enforce column vector
                 lickRates.(pre_post{j}).(fields{k}); %Lick rates pre- & post-cue, for comparing, eg, pre-cue lick rate in sound vs action.
        end
    end
end

% Differences in Left vs Right Lick Rates
cue = {'upsweep','downsweep','all'};
rule = {'sound','actionL','actionR'};
for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    for j = 1:numel(pre_post)
        for k = 1:numel(cue)
            for kk = 1:numel(rule)
             B.(cellType{i}).lickDiffs.(pre_post{j}).(cue{k}).(rule{kk})(idx,:) = ... %Enforce column vector
                 lickDiffs.(pre_post{j}).(cue{k}).(rule{kk}); 
            end
        end
    end
end
