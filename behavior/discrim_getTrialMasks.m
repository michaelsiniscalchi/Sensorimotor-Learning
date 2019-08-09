function [ trials ] = discrim_getTrialMasks( trialData )
% % getTrialMasks %
%PURPOSE:   Create data structure, 'trials', containing logical masks
%           of size(nTrials,1) for task variables.
%AUTHORS:   MJ Siniscalchi 161214.
%   
%
%INPUT ARGUMENTS
%   trialData:  Structure generated by flex_getSessionData()
%
%OUTPUT VARIABLES
%   trials:     Structure containing these fields, each a logical mask
%               indicating whether trial(idx) is of the corresponding subset, e.g.,
%               response==left or cue==upsweep.
%
%--------------------------------------------------------------------------

%% GET CODES FROM PRESENTATION
[STIM,RESP,OUTCOME,EVENT] = flex_getPresentationCodes(1); %Only one codeset is used currently...

%% GET MASKS FOR THOSE RESP/OUTCOME/RULE TYPES WITH CLEAR MAPPINGS
taskVar = {'cue' 'response' 'outcome'};

for i = 1:numel(taskVar)
    clear codes;
    switch taskVar{i}
        case 'cue'
            codes.upsweep = [STIM.sound_UPSWEEP,...
                                STIM.left_UPSWEEP,...
                                STIM.right_UPSWEEP];
            codes.downsweep = [STIM.sound_DNSWEEP,...
                                STIM.left_DNSWEEP,...
                                STIM.right_DNSWEEP];
        case 'response'
            codes.left = [RESP.LEFT];
            codes.right = [RESP.RIGHT];
        case 'outcome'
            codes.hit = [OUTCOME.REWARDLEFT,...
                        OUTCOME.REWARDRIGHT];
            codes.err = [OUTCOME.NOREWARD];                        
            codes.miss = [OUTCOME.MISS];
    end
    
    fields = fieldnames(codes);
    for j = 1:numel(fields)
        trials.(fields{j}) = ismember(trialData.(taskVar{i}),codes.(fields{j})); %Generate trial mask for each field in 'codes'
    end
    
end

%% GET MASK FOR REACTION (first lick after cue, not necessarily in response window)
trials.reactionLeft = (trialData.reaction == RESP.LEFT);
trials.reactionRight = (trialData.reaction == RESP.RIGHT);

%% Verify that cue was presented in each trial
if sum(trials.upsweep)+sum(trials.downsweep) ~= numel(trials.hit)
    disp('ERROR in flex_getTrialMasks: number of sound cues should equal the total number of trials.');
end