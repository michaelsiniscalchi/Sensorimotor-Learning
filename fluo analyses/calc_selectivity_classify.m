function ROC = calc_selectivity( trial_dFF, trials, label, params )

%Initialize parallel pool
%disp(gcp); %Query/initialize

tic 

% Unpack variables from structures
trial_dff  = trial_dFF.cueTimes; %***FUTURE, could include arg 'trigger'
decodeSpec = strcmp(params.label,label); %Find idx for the specified trialSpec, etc. 
trialSpec  = params.trialSpec(decodeSpec,:);
nShuffle   = params.nShuffle;
CI         = params.CI; 

% Initialize output variables 
%decode.(params.label{decodeSpec}).accuracy    = cell([numel(trial_dff), 1]);  
ROC.(params.label{decodeSpec}).selectivity = cell([numel(trial_dff), 1]); %Pre-allocate memory for cell header
ROC.(params.label{decodeSpec}).shuffle     = cell([numel(trial_dff), nShuffle]); 
ROC.(params.label{decodeSpec}).trialSpec = trialSpec;
ROC.t = trial_dFF.t;

% Generate grouping vector
for i = 1:numel(trialSpec)
    trialMasks(:,i) = getMask(trials,trialSpec{i}); %#ok<AGROW> %Logical mask for specified combination of trials
end
subset = any(trialMasks,2); %Include only trials for comparison
types = trialMasks(subset,:); %Logical of dim nTrials x nTrialSpecs 
types = uint8(sum((1:size(types,2)).*types,2)); %Convert to uint8 grouping var: trial type coded as column index

% Downsample aligned dF/F if specified
if ~isempty(params.dsFactor)
    [trial_dff, ROC.t] = downsampleTS(trial_dff,ROC.t,params.dsFactor);
end

% Disable warning
warning('off','stats:perfcurve:SubSampleWithMissingClasses'); %LOOCV, so classes always missing from each test set

% Decode aligned dF/F at each timepoint
for i = 1:numel(trial_dff)
    disp(['Decoding ' params.label{decodeSpec} ' from cell ' num2str(i) '/' num2str(numel(trial_dff)) '...']);  
   
    %Get only trials specified in trialMasks
    dff = trial_dff{i}(subset,:); 
    
    % Initialize variables for parallelization
    ACCURACY = NaN(size(dff,2),1);
    AUROC = NaN(size(dff,2),3);
    ACCURACY_SHUFFLE = NaN(size(dff,2),3);
    
    % Decoding accuracy and CI for shuffle 
    for t = 1:size(dff,2) 
        %AUROC
        [ TPR, FPR, AUC ] = calc_ROC(dff(:,t),types,1);
        %Decoding accuracy
        [ACCURACY(t), AUROC(t,:)] = decodeTrialType(dff(:,t),types,classifier);
        %CI for accuracy on shuffled data
        ACCURACY_SHUFFLE(t,:) = decodeTrialShuffle(dff(:,t),types,nShuffle,CI,classifier); %Shuffle trial types and use identical classification method
    end
    % Store results in structure
    ROC.(params.label{decodeSpec}).accuracy{i} = ACCURACY;
    ROC.(params.label{decodeSpec}).selectivity{i} = 2*(AUROC-0.5);
    ROC.(params.label{decodeSpec}).shuffle{i} = ACCURACY_SHUFFLE;
end
toc

%% Internal functions

function [ds_dff, ds_time] = downsampleTS(trial_dff,time,dsFactor)

dsIdx = 1:dsFactor:numel(time);
ds_time = time(dsIdx(1:end-1))+ diff(time(dsIdx))/2; %Midpoint between downsampled timepoints
ds_dff = cell(size(trial_dff));
for i = 1:numel(trial_dff)
    for j = 1:numel(ds_time)
        idx = dsIdx(j):dsIdx(j+1)-1; 
        ds_dff{i}(:,j) = nanmean(trial_dff{i}(:,idx),2); %Assign mean across timepoints
    end
end

% ------- NOTES -----------------------------------------------------------

% %Store in structure compatible with plotting functions
%     selectivity(i).t = tByTrial;
%     selectivity(i).signal = selIdx(:,1);
%     selectivity(i).CI = selIdx(:,2:3);
%     selectivity(i).subset_label = subset_label;
%     selectivity(i).nEvent = [sum(trialType1),sum(trialType2)];