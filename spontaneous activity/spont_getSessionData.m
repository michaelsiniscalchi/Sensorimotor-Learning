function [ sessionData ] = spont_getSessionData( logData )
% % getSessionData %
%PURPOSE: Retrieve session data for flexibility task.
%AUTHORS: MJ Siniscalchi 161212.
%         modified by AC Kwan 170515
%         modified by MJ Siniscalchi 180504
%
%INPUT ARGUMENTS
%   logdata:    Structure obtained with a call to parseLogfile().
%   presCodeSet:   Which set of Presentation event code set was used
%
%OUTPUT VARIABLES
%   sessionData:    Structure containing these fields:
%                   {subject, dateTime, nTrials, *lickTimes, *nSwitch}.
%                   * lickTimes([1 2]):=[left right] lick times.

%% What event codes were used?

%COPY FROM LOGDATA
sessionData.subject = logData.subject;
sessionData.dateTime = logData.dateTime;

%SESSION DATA <<logData.header: 'Subject' 'Trial' 'Event Type' 'Code' 'Time'>>
TYPE = logData.values{3}; %Intersectional approach necessary, because values 2,3 were reused;
CODE = logData.values{4}; %change in future Presentation scripts: with unique codes, only CODE would be needed to parse the logfile...

tempidx=(strcmp(TYPE,'Nothing') | strcmp(TYPE,'Sound')); %do not consider RESPONSE or MANUAL
codeUsed = unique(CODE(tempidx));         %List the set of event codes found in this logfile
sessionData.presCodeSet = 2;
[ ~, RESP, ~, EVENT ] = flex_getPresentationCodes(2); %(sessionData.presCodeSet = 2)

%% Set up the time axis, and identify lick times
time_0 = logData.values{5}(find(CODE==EVENT.STARTEXPT,1,'first'));
if isempty(time_0)
    disp('ERROR in flex_getSessionData: there are no StartExpt event codes found in the log file.');
    disp('   check the expParam.presCodeSet used for flex_getPresentationCodes');
else
    time = logData.values{5}-time_0;   %time starts at first instance of startExpt
end
time = double(time)/10000;         %time as double in seconds

sessionData.lickTimes{1} = time(strcmp(TYPE,'Response') & CODE==RESP.LEFT);    %left licktimes
sessionData.lickTimes{2} = time(strcmp(TYPE,'Response') & CODE==RESP.RIGHT);   %right licktimes

sessionData.imgTrigTimes = time(CODE==EVENT.STARTEXPT);

end

