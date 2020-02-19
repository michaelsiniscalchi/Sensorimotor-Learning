function stats = summary_stats( stats, input, type )

%BE CAREFUL ABOUT TREATMENT OF NANS!

switch type
   
    case 'behavior'
        cellTypes = fieldnames(input);
        for i = 1:numel(cellTypes)

            %Total number of trials & trials performed 
            expID = input.(cellTypes{i}).sessionID;
            S.(cellTypes{i}).nTrials = calcStats(input.(cellTypes{i}).nTrials,expID);
            S.(cellTypes{i}).trialsCompleted = calcStats(input.(cellTypes{i}).trialsCompleted,expID);

            %Total number of blocks completed
            S.(cellTypes{i}).blocksCompleted = calcStats(input.(cellTypes{i}).blocksCompleted,expID);
            
            %Block performance
            vbl = {'trials2crit','pErr','oErr'};
            rule = {'sound','action'};
            for j = 1:numel(vbl)
                for k = 1:numel(rule)
                    S.(cellTypes{i}).(vbl{j}).(rule{k}) = ...
                        calcStats(input.(cellTypes{i}).(vbl{j}).(rule{k}),expID);
                end
            end
  
            %Lick Density
            choice = {'left','right'};
            cue = {'upsweep','downsweep'}; 
            rule = {'sound','actionL','actionR'};
            for ii = 1:numel(choice)
                for jj = 1:numel(cue)
                    for kk = 1:numel(rule)
                        data = input.(cellTypes{i}).lickDensity.(choice{ii}).(cue{jj}).(rule{kk});
                        S.(cellTypes{i}).lickDensity.(choice{ii}).(cue{jj}).(rule{kk}) = ...
                            calcStats(data,expID);
                    end
                end
            end
            
            %Lick rates pre- & post-cue
            pre_post = {'preCue','postCue'};
            for j = 1:numel(pre_post)
                fields = fieldnames(input.(cellTypes{i}).lickRates.(pre_post{j}));
                for k = 1:numel(fields)
                    data = input.(cellTypes{i}).lickRates.(pre_post{j}).(fields{k});
                    S.(cellTypes{i}).lickRates.(pre_post{j}).(fields{k}) = ...
                        calcStats(data,expID); %Lick rates pre- & post-cue, for comparing, eg, pre-cue lick rate in sound vs action.
                end
            end
            
            % Differences in Left vs Right Lick Rates
            cue = {'upsweep','downsweep','all'};
            rule = {'sound','actionL','actionR'};
            for j = 1:numel(pre_post)
                for k = 1:numel(cue)
                    for kk = 1:numel(rule)
                        data = input.(cellTypes{i}).lickDiffs.(pre_post{j}).(cue{k}).(rule{kk});
                        S.(cellTypes{i}).lickDiffs.(pre_post{j}).(cue{k}).(rule{kk}) = ... %Enforce column vector
                            calcStats(data,expID); %Differences between left & right lick rates pre- & post-cue by rule and cue
                    end
                end
            end
            
            %Performance curve surrounding rule switch
            rule = {'sound','action','all'};
            vbl = {'hit','pErr','oErr','miss'}; %Proportion hit, pErr, oErr, & miss, by session
            
            for j = 1:numel(vbl)
                for k = 1:numel(rule)
                    data = input.(cellTypes{i}).perfCurve.(vbl{j}).(rule{k});
                    S.(cellTypes{i}).perfCurve.(vbl{j}).(rule{k}) = ...
                        calcStats(data,expID);
                    %Performance on last trial of block & next trial
                    S.(cellTypes{i}).perfLastTrial.(vbl{j}).(rule{k}) = ...
                        calcStats(data(:,20),expID); %perfCurve is switchtrial+[-20:19]; lastIdx = 20;
                    S.(cellTypes{i}).perfNextTrial.(vbl{j}).(rule{k}) = ...
                        calcStats(data(:,21),expID); %nextIdx = 21; 
                end
            end
  
        end
  
    case 'imaging'
        cellTypes = fieldnames(input);
        for i = 1:numel(cellTypes)
            % Number of blocks imaged 
            expID = input.(cellTypes{i}).sessionID; 
            S.(cellTypes{i}).nBlocksImg = calcStats(input.(cellTypes{i}).nBlocksImg,expID);
            % Number of cells total/included/excluded
            S.(cellTypes{i}).totalCells = calcStats(input.(cellTypes{i}).totalCells,expID);
            S.(cellTypes{i}).inclCells = calcStats(input.(cellTypes{i}).inclCells,expID);
            S.(cellTypes{i}).exclCells = calcStats(input.(cellTypes{i}).exclCells,expID);
            S.(cellTypes{i}).exclMasks = calcStats(input.(cellTypes{i}).exclMasks,expID);
            % Number of task-responsive cells (diff. pre-post cue ~=0)
            S.(cellTypes{i}).nTaskCells = calcStats(input.(cellTypes{i}).nTaskCells,expID);
            S.(cellTypes{i}).pTaskCells = calcStats(input.(cellTypes{i}).pTaskCells,expID);
        end
        
    case 'selectivity'
        
        %Get Mean, SEM, N, and Exp. ID for each terminal node in struct selectivity
        decodeTypes = fieldnames(input);
        decodeTypes = decodeTypes(~strcmp(decodeTypes,'t'));
        time = input.t;
        for i = 1:numel(decodeTypes)
            cellTypes = fieldnames(input.(decodeTypes{i}));
            for j = 1:numel(cellTypes)
                varNames = fieldnames(input.(decodeTypes{i}).(cellTypes{j})); %varNames = {'selMag','sigMag','pSig','nPref_pos','nPref_neg','nCells'};
                varNames = varNames(~ismember(varNames,{'cellID','expID'}));
                for k = 1:numel(varNames)
                    % Unpack & get session ID
                    vbl = input.(decodeTypes{i}).(cellTypes{j}).(varNames{k}); 
                    expID = input.(decodeTypes{i}).(cellTypes{j}).expID; %For pooled cells from many sessions
                    if numel(expID) > size(vbl,1) %For data aggregated by session 
                        expID = unique(expID); 
                    end
                    % Estimate descriptive stats
                    S.(decodeTypes{i}).(cellTypes{j}).(varNames{k}) = ...
                        calcStats(input.(decodeTypes{i}).(cellTypes{j}).(varNames{k}),expID);
                end
            end
        end
        
    case 'transitions'
        
        cellTypes   = fieldnames(input); %Cell types, ie 'SST','VIP','PV','PYR', or 'all'
        transTypes  = fieldnames(input.(cellTypes{1})); %Transition types, eg 'all','sound', or 'sound_actionR'
        for i = 1:numel(cellTypes)
            for j = 1:numel(transTypes)
                % Label with corresponding session idx
                expID = input.(cellTypes{i}).(transTypes{j}).sessionID;
                                
                % Estimate descriptive stats for binned data
                S.(cellTypes{i}).(transTypes{j}).binValues = calcStats(input.(cellTypes{i}).(transTypes{j}).binValues,expID);
                S.(cellTypes{i}).(transTypes{j}).binIdx = input.(cellTypes{i}).(transTypes{j}).binIdx; %Copy bin indices

                % Change points
                neuralChgPt = input.(cellTypes{i}).(transTypes{j}).changePt1; %Neural; MATLAB ipt = findchangepts(x)
                behChgPt = input.(cellTypes{i}).(transTypes{j}).behChangePt2; %Behavioral; minimum cumulative deviation
                                
                idx = ~isnan(neuralChgPt) & ~isnan(behChgPt); %Remove entries with NaN for either change-point
                [neuralChgPt,behChgPt,expID] = ...
                    deal(neuralChgPt(idx),behChgPt(idx),expID(idx));

                S.(cellTypes{i}).(transTypes{j}).neuralChgPt = calcStats(neuralChgPt,expID); % Estimate descriptive stats
                S.(cellTypes{i}).(transTypes{j}).behChgPt = calcStats(behChgPt,expID);
                
                %Copy nTrials from summary
                S.(cellTypes{i}).(transTypes{j}).nTrials = ...
                    input.(cellTypes{i}).(transTypes{j}).nTrials(idx);
            end
        end
end
stats.(type) = S;