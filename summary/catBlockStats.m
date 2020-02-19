function B = catBlockStats( B, blocks, expIdx )

%Index the relevant rule blocks
excl = [true; false(numel(blocks.type)-2,1); true]; %Exclude first and last block
blkIdx.sound = strcmp(blocks.type,'sound') & ~excl;
blkIdx.action = ismember(blocks.type,{'actionL','actionR'}) & ~excl;

cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
rule = fieldnames(blkIdx);

for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    B.(cellType{i}).blocksCompleted(idx,:) = numel(blocks.type)-1; %Total number of blocks completed (ie, excl. last)
    for j = 1:numel(rule)
        %Trials to criterion
        B.(cellType{i}).trials2crit.(rule{j})(idx,:) = mean(blocks.nTrials(blkIdx.(rule{j})));
        %Perseverative errors
        B.(cellType{i}).pErr.(rule{j})(idx,:) = mean(blocks.pErr(blkIdx.(rule{j})));
        %Other errors
        B.(cellType{i}).oErr.(rule{j})(idx,:) = mean(blocks.oErr(blkIdx.(rule{j})));
    end
end

