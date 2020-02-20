function [ STIM, RESP, OUTCOME, EVENT ] = getPresentationCodes(presCodeSet)
%%% getPresentationCodes()
%
%PURPOSE: To read and parse Presentation logfile for further analysis.
%AUTHORS: MJ Siniscalchi & AC Kwan, 161209. 
%           -Edited 190703mjs
%
%OUTPUT VARIABLES
%   presCodeSet:    Allow flexibility for different sets of event codes (use 1)
%
%OUTPUT VARIABLES
%   STIM:     fields containing stimulus-related eventCode defined in Presentation
%   RESP:     fields containing response-related eventCode defined in Presentation
%   OUTCOME:  fields containing outcome-related eventCode defined in Presentation
%   EVENT:    fields containing other event-related eventCode defined in Presentation

if presCodeSet == 1
    STIM.sound_UPSWEEP=21;  %Sound Rule/Upsweep...OR Simple Discrimination Task: upsweep
    STIM.sound_DNSWEEP=22;  %Sound Rule/Downsweep...OR Simple Discrimination Task: downsweep
    STIM.left_UPSWEEP=23;   %Rule/Sound cue combo: Action-Left/UpSweep
    STIM.left_DNSWEEP=24;
    STIM.right_UPSWEEP=25;  %Rule/Sound cue combo: Action-Right/UpSweep
    STIM.right_DNSWEEP=26;
        
    RESP.LEFT=2;
    RESP.RIGHT=3;
    
    OUTCOME.REWARDLEFT=5;   %Following hit
    OUTCOME.REWARDRIGHT=6;
    OUTCOME.NOREWARD=7;     %aka Timeout event in Presentation
    OUTCOME.MISS=8;         %aka Pause event in Presentation
    
    EVENT.STARTTRIAL = 4;
    EVENT.ENDTRIAL = 9;      %Begins inter-trial period
    
else
    error('Code set is invalid...may need to write a new elseif block to identify codes from NBS Presentation');
end

