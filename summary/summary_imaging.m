function IMG = summary_imaging( struct_img, params )

% Initialize output structure
type = {'SST','VIP','PV','PYR','all'};
for i = 1:numel(type)
    IMG.(type{i}) = struct(...
        'sessionID',[],'nBlocksImg',[],'totalCells',[],'inclCells',[],'exclCells',[],'exclMasks',[]);
end

% Aggregate data from each session into pooled and cell-type-specific data structures
for sessionID = 1:numel(struct_img)
    
    % Data by session: SessionIdx, nTrials, trialsCompleted
    S = struct_img(sessionID);
    expIdx.all = sessionID;
    expIdx.(S.cellType) = sum(strcmp({struct_img(1:sessionID).cellType},S.cellType)); %Cell type spec sessionIdx
    
    type = fieldnames(expIdx); %Eg, {'all','SST'}
    for j = 1:numel(type)     
        %Session ID numbers
        IMG.(type{j}).sessionID(expIdx.(type{j}),:) = sessionID;
        %Number of rule blocks succesfully imaged
        IMG.(type{j}).nBlocksImg(expIdx.(type{j}),:) = numel(S.blocks.type)-1; %Number of blocks analyzed for imaging results (last block always excl)
        %Cell counts and exclusions
        nExcl = sum(ismember(S.exclude.crit,'npF0>F0')); %Only current excl. crit is 'npF0>F0'; else, 'F==NaN'; if so, CHECK! 
        IMG.(type{j}).totalCells(expIdx.(type{j}),:) = numel(S.cellID) + nExcl; %Number of cells from 'cellROI.m' (not counting excl. masks)
        IMG.(type{j}).inclCells(expIdx.(type{j}),:) = numel(S.cellID); %Number of cells analyzed
        IMG.(type{j}).exclCells(expIdx.(type{j}),:) = nExcl;
        IMG.(type{j}).exclMasks(expIdx.(type{j}),:) = size(S.exclude.cells,1)-nExcl; %If exclCells>exclBkgd, 'F==NaN'; if so, CHECK!
        %***FUTURE: 'exclude.cells' should be string, not char...
        
        %Number & Proportion of Task-Responsive Cells per Session for each Cell-Type
        [N,P,isTaskCell] = getTaskCells(S.trialDFF, ~S.trials.miss, params.window, 0.05); %Neurons whose activity differs pre/post cue @ alpha=0.5
        IMG.(type{j}).nTaskCells(expIdx.(type{j}),:) = N;
        IMG.(type{j}).pTaskCells(expIdx.(type{j}),:) = P;
        IMG.(type{j}).isTaskCell{expIdx.(type{j})} = isTaskCell;
        
        %Mean traces from all task responsive cells by cell-type?
        
    end
    
    clearvars expIdx
end


