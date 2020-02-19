function B = summary_behavior( struct_beh, params )

% Initialize output structure
type = {'SST','VIP','PV','PYR','all'};
perfData = struct('sound',[],'action',[]);
for i = 1:numel(type)
    B.(type{i}) = ...
        struct('sessionID',[],'nTrials',[],'trialsCompleted',[],'blocksCompleted',[],...
        'trials2crit',perfData,'oErr',perfData,'pErr',perfData,...
        'lickDensity',struct(),'lickRates',struct(),'perfCurve',struct());
end

% Aggregate data from each session into pooled and cell-type-specific data structures
for sessionID = 1:numel(struct_beh)
    
    % Data by session: SessionIdx, nTrials, trialsCompleted
    S = struct_beh(sessionID);
    expIdx.all = sessionID;
    expIdx.(S.cellType) = sum(strcmp({struct_beh(1:sessionID).cellType},S.cellType)); %Cell type spec sessionIdx
    
    type = fieldnames(expIdx); %Eg, {'all','SST'}
    for j = 1:numel(type)
        B.(type{j}).sessionID(expIdx.(type{j}),:) = sessionID;
        B.(type{j}).nTrials(expIdx.(type{j}),:) = numel(S.trialData.cue);
        B.(type{j}).trialsCompleted(expIdx.(type{j}),:) = sum(~S.trials.miss);
    end
    
    % Lick density by Cue and Rule
    edges = params.timeWindow(1):params.binWidth:params.timeWindow(2);
    lickDensity = getLickDensity(S.trialData,S.trials,edges); %Organized heirarchically by choice, cue, then rule
    B = catLickDensity(B,lickDensity,S.cellType); %Concatenate current structure with group at terminal fields of heirarchy
    
    % Lick rates surrounding cue in varying trial conditions
    lickRates = getLickRates(S.trialData, S.trials, params.preCueBinWidth); %For comparisons eg, pre-cue lick rate in action vs sound
    lickDiffs = getLickDiffs(S.trialData, S.trials, params.preCueBinWidth); 
    B = catLickRates(B,lickRates,lickDiffs,expIdx);
    
    % Block data: median pErr, oErr, & trials2crit
    B = catBlockStats(B,S.blocks,expIdx);
    
    % Density of each outcome surrounding rule switch
    B = catSwitchPerf(B,S.trials,S.blocks,expIdx);
    
    clearvars expIdx
end