%%% getImgBehData()
%
%PURPOSE: To reconcile behavioral data acquired in NBS Presentation with
%           calcium imaging data simultaneously acquired in ScanImage.
%
%AUTHOR: MJ Siniscalchi, 190904

function results = get_combinedData( beh_data, stack_info )

% Session Identifier: [DATE SUBJECT]
sessionID = [datestr(beh_data.sessionData.dateTime{1},'yymmdd '), beh_data.sessionData.subject];

% Check if number of trials from behavior is equal to number of raw imaging substacks
B = numel(beh_data.trialData.cue);
S = numel(stack_info.rawFileName);

% Initialize data structures from input
trialData = beh_data.trialData;
trials = beh_data.trials;

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
          
else
    disp([sessionID ': No inconsistencies found.']);
end

%Assign fields
results.sessionID = sessionID;
results.trialData = trialData;
results.trials = trials;
results.stackInfo = stack_info;

%NOTE: Later in processing, fieldnames will be added to store cellular fluorescence data.