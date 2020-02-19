function [ sessionData, trialData ] = getSessionData( logData )
% % getSessionData %
%PURPOSE: Retrieve session data for flexibility task.
%AUTHORS: MJ Siniscalchi 161212.
%         edited 190701mjs
%
%INPUT ARGUMENTS
%   logdata:    Structure obtained with a call to parseLogfile().
%
%OUTPUT VARIABLES
%   sessionData:    Structure containing these fields:
%                   {subject, dateTime, nTrials, *lickTimes, *nSwitch}.
%                   * lickTimes([1 2]):=[left right] lick times.
%   trialData:      Fields:
%                   {startTimes, cueTimes, outcomeTimes, *cue, *response, *outcome}
%               *cue, response, and outcome for each trial contains
%               corresponding event code from NBS Presentation
%--------------------------------------------------------------------------

%% Extract data from 'logData'

% Get subject ID, date, and code values 
sessionData.subject = upper(logData.subject{:});
sessionData.dateTime = logData.dateTime;
CODE = logData.values{4}; %logData.header = {'Subject' 'Trial' 'Event Type' 'Code' 'Time'}

% Generate structure to reference event codes from NBS Presentation
[ STIM, RESP, OUTCOME, EVENT ] = getPresentationCodes(1);
cueCodes = cell2mat(struct2cell(STIM)); %Numeric vector containing all stimulus-associated codes
outcomeCodes = cell2mat(struct2cell(OUTCOME)); %outcome-associated codes
respCodes = cell2mat(struct2cell(RESP));     %response-associated codes

% Truncate data to last completed trial
lastTrialEnd = find(CODE==EVENT.ENDTRIAL,1,'last'); 
CODE = CODE(1:lastTrialEnd); 

% Initialize data structure
sessionData.nTrials = numel(CODE(ismember(CODE,outcomeCodes))); %Total number of trials
trialData = initTrialData(sessionData.nTrials);

%% Cues & Outcomes: record numeric vector of event codes
trialData.cue = CODE(ismember(CODE,cueCodes)); %Cue codes 
trialData.outcome =  CODE(ismember(CODE,outcomeCodes)); %Outcome codes

%% Calculate absolute event times

% Define time line
time_0 = logData.values{5}(find(CODE==EVENT.STARTTRIAL,1,'first'));
time = logData.values{5} - time_0;   %time starts at first instance of startExpt
time = double(time)/10000;         %time as double in seconds

% For trialData: absolute timing of events that define trial structure
trialData.startTimes = time(CODE==EVENT.STARTTRIAL);
trialData.cueTimes = time(ismember(CODE,cueCodes));
trialData.outcomeTimes = time(ismember(CODE,outcomeCodes));

% For sessionData: store timing of all licks in session
sessionData.lickTimes{1} = time(CODE==RESP.LEFT);    %Left lick times
sessionData.lickTimes{2} = time(CODE==RESP.RIGHT);   %Right lick times
sessionData.timeLastEvent = [num2str(time(end)/60,5) ' min'];   %Time of the last event logged

%% Timing and direction of each response

% Infer grace period duration
if nanmin(trialData.outcomeTimes - trialData.cueTimes) >= 0.4
    sessionData.gracePeriodDur = 0.5;  %grace period of 0.5 s was employed for many early studies in the lab
else
    sessionData.gracePeriodDur = 0;    %no grace period
end

% Extract response data from all relevant trials
idx = find(trialData.outcome~=OUTCOME.MISS); %Trial idx: all non-miss trials
respIdx = find(ismember(CODE,respCodes)); %Event idx: all lick responses
respTimes = time(respIdx); %Absolute timing of each response
for i = 1:numel(idx)
    %Timing of the lick recorded as animal's choice
    firstLick = find(respTimes>=(trialData.cueTimes(idx(i))+sessionData.gracePeriodDur),1,'first'); %First lick within response window
    trialData.response(idx(i)) = CODE(respIdx(firstLick));
    trialData.responseTimes(idx(i)) = respTimes(firstLick);   %In absolute time (only ~1ms different from outcomeTimes) 
end

%% Lick times, lick counts, and reaction times from all trials

% Find event times across multiple trials relative to cue onset 
getRelTimes = @(trial_index,t,abs_times)... 
    abs_times(abs_times>t(1) & abs_times<=t(2)) - trialData.cueTimes(trial_index);

for i = 1:sessionData.nTrials 

    %Extract reaction times: first response following cue
    firstLick = find(respTimes>=trialData.cueTimes(i),1,'first'); 
    if ~isempty(firstLick) && trialData.outcome(i)~=OUTCOME.MISS %If at least one reactive lick recorded
        relTimes = respTimes-respTimes(firstLick); %Time relative to first lick
        if ~any(relTimes > -0.5 & relTimes < 0) %Exclude "reactions" that are part of a pre-existing lick-bout
            trialData.reaction(i) = CODE(respIdx(firstLick));
            trialData.reactionTimes(i) = respTimes(firstLick)-trialData.cueTimes(i);   %Timing relative to cue
        end
    end

    % Lick times relative to each cue onset
    if i==1
        t = [0,trialData.cueTimes(i+1)];
    elseif i==sessionData.nTrials
        t = [trialData.cueTimes(i-1),time(end)];
    else
        t = [trialData.cueTimes(i-1),trialData.cueTimes(i+1)];
    end
    trialData.lickTimesLeft{i}  = getRelTimes(i,t,sessionData.lickTimes{1})'; %Lick times relative to cue
    trialData.lickTimesRight{i} = getRelTimes(i,t,sessionData.lickTimes{2})';
    
    %Lick counts prior to cue and reward
    t = [trialData.cueTimes(i)-0.5, trialData.cueTimes(i)]; %Between -0.5 and cue onset
    trialData.nLicksPreCue(i) = numel(getRelTimes(i,t,respTimes)); %Lick count within pre-cue window
    
    t = [trialData.cueTimes(i), trialData.cueTimes(i)+sessionData.gracePeriodDur];
    trialData.nLicksPreRew(i) = numel(getRelTimes(i,t,respTimes)); %Lick count between cue onset and response window      
    
    %Lick counts following cue
    win = 5; %Within 5 s of cue onset
    LT = {trialData.lickTimesLeft{i}, trialData.lickTimesRight{i}};
    trialData.nLicksLeft(i) = sum(LT{1}>0 & LT{1}<=win); %Record licks within time range
    trialData.nLicksRight(i) = sum(LT{2}>0 & LT{2}<=win);
    
end

%% Internal functions
function trialData = initTrialData( nTrials )
trialData.cue = zeros(nTrials,1,'uint8');           %Cue code from NBS Presentation logfile
trialData.reaction = zeros(nTrials,1,'uint8');      %Direction of first lick following cue
trialData.response = zeros(nTrials,1,'uint8');      %Direction of first lick during response period 
trialData.outcome =  zeros(nTrials,1,'uint8');      %Outcome code from NBS Presentation logfile

trialData.startTimes = NaN(nTrials,1);
trialData.cueTimes = NaN(nTrials,1);
trialData.reactionTimes = NaN(nTrials,1);           %Time of the first lick following cue 
trialData.responseTimes = NaN(nTrials,1);           %Time of first lick during response period
trialData.outcomeTimes = NaN(nTrials,1);

trialData.nLicksPreCue = zeros(nTrials,1,'uint8');  %Lick rate during the 500ms pre-cue
trialData.nLicksPreRew = zeros(nTrials,1,'uint8');  %Lick rate during the 500ms grace period, if present
trialData.nLicksLeft = zeros(nTrials,1,'uint8');    %Lick counts for the 5 s following cue onset 
trialData.nLicksRight = zeros(nTrials,1,'uint8');

trialData.lickTimesLeft = cell(nTrials,1);          %Lick times for each lick direction
trialData.lickTimesRight = cell(nTrials,1);

