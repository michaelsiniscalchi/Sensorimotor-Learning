function stats = calc_lickStats( trialData, trials, stats )

%Abbreviate struct vars
t=trials;
tD=trialData;

%Trial subset for most calculations
reaction = (t.reactionLeft | t.reactionRight) & ~t.miss; 

%% Reaction Time
stats.medianRT = median(tD.reactionTimes(reaction));
stats.medianRT_hit = median(tD.reactionTimes(reaction & t.hit));
stats.medianRT_err = median(tD.reactionTimes(reaction & t.err));

%% Proportion of trials with correct reaction

corrReaction = ((t.upsweep & t.reactionLeft)|(t.downsweep & t.reactionRight)) & ~t.miss;
stats.pCorrectReaction = sum(corrReaction)/sum(reaction); %Proportion correct reaction out of all trials performed
stats.pCorrectReactionHit = sum(corrReaction & t.hit)/sum(reaction & t.hit); %Proportion correct reaction out of all hit trials (correct reaction, correct response)
stats.pCorrectReactionErr = sum(corrReaction & t.err)/sum(reaction & t.err); %Proportion correct reaction out of all err trials (correct reaction, wrong response)

%Proportion of trials with same reaction and response
stats.pSameReactResp =...
    sum(((t.reactionLeft & t.left)|(t.reactionRight & t.right)) & ~t.miss)/sum(reaction);

%% Calculate lick density pre-cue vs. grace period in trials performed
stats.avgLicksPreCue = mean(tD.nLicksPreCue(~t.miss));
stats.avgLicksPreRew = mean(tD.nLicksPreRew(~t.miss));
stats.ratioPreCuePreRew = stats.avgLicksPreCue\stats.avgLicksPreRew;

% Proportion of trials with pre-cue licking
stats.pPreCueTrials = sum(tD.nLicksPreCue(~t.miss)>0)...
    /sum(~t.miss); %(N trials with pre-cue licking)/(N trials with a response)
