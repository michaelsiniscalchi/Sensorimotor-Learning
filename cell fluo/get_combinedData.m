%%% getImgBehData()
%
%PURPOSE: To reconcile behavioral data acquired in NBS Presentation with
%           calcium imaging data simultaneously acquired in ScanImage.
%
%AUTHOR: MJ Siniscalchi, 190904

function results = get_combinedData( beh_data, stack_info )

% Session Identifier: [DATE SUBJECT TASK]
sessionID = [datestr(beh_data.sessionData.dateTime{1},'yymmdd ')...
    beh_data.sessionData.subject ' RuleSwitching'];

% Check if number of trials from behavior is equal to number of raw imaging substacks
B = numel(beh_data.trialData.cue);
S = numel(stack_info.rawFileName);

% Initialize data structures from input
trialData = beh_data.trialData;
trials = beh_data.trials;
fields = {'type','firstTrial','nTrials'}; %Include only these fields from struct 'blocks'
for i = 1:numel(fields)
blocks.(fields{i}) = beh_data.blocks.(fields{i});
end

if B < S
    %Truncate imaging data to match behavioral data
    fields = {'rawFileName','nFrames','trigTime','trigDelay'};
    for j = 1:numel(fields)
        stack_info.(fields{j}) = stack_info.(fields{j})(1:B);
    end
    disp([sessionID ': '  'Image header information truncated to '...
        num2str(B) ' trials.']);
    
elseif B > S  % Truncate behavioral data to match imaging data

    %Trial data
    fields = fieldnames(trialData);
    for j = 1:numel(fields)
        trialData.(fields{j}) = trialData.(fields{j})(1:S);
    end
    
    %Trial masks
    fields = fieldnames(trials);
    for j = 1:numel(fields)
        trials.(fields{j}) = trials.(fields{j})(1:S);
    end
    
    %Block data
    idx = 1:sum(blocks.firstTrial<S);
    fields = fieldnames(blocks);
    for j = 1:numel(fields)
        blocks.(fields{j}) = blocks.(fields{j})(idx); %Exclude remaining fields used only for behavioral analysis 
    end
    blocks.nTrials(end) = numel(trialData.cue) - sum(blocks.nTrials(1:end-1)); %Truncate nTrials(end) to last trial of imaging data
    
    disp([sessionID ': Behavioral data truncated to '...
        num2str(numel(trialData.cue)) ' trials.'...
        ' (' num2str(numel(blocks.firstTrial)) ' remaining rule switches.)']);
    
else
    disp([sessionID ': No inconsistencies found.']);
end

%Assign fields
results.sessionID = sessionID;
results.trialData = trialData;
results.trials = trials;
results.blocks = blocks;
results.stackInfo = stack_info;

%NOTE: Later in processing, fieldnames will be added to store cellular fluorescence data.