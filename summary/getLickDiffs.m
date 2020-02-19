%%% getLickDiffs()
%
% PURPOSE: To get mean lick rate for an entire session behavioral within a fixed timerange 
%           pre & post cue.
% AUTHOR: MJ Siniscalchi, 200209
%
% INPUT ARGUMENTS:
%                   'trialData', 'trials': Structures generated by 'getTrialData.m' and
%                       'getTrialMasks.m', respectively.
%                   'binWidth' : Duration from cue to consider in mean lick rate calculation.
%
%---------------------------------------------------------------------------------------------------
function lickDiffs = getLickDiffs( trialData, trials, binWidth )

%% LICK RATES PRE- & POST-CUE

% Post-cue difference in right-left lick rate for comparison of Sound & Action trials
L = trialData.lickTimesLeft;
R = trialData.lickTimesRight;
cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};

for i = 1:numel(rule)
    for j = 1:numel(cue)
        %For each rule x cue combination
        trialSpec = {rule{i}, cue{j}, 'last20'};
        
        [leftRate_pre, leftRate_post] = ...
            getPeriCueLickRates(L, getMask(trials,trialSpec), binWidth); % lickTimesAll(:,1) contains the left lick-times
        [rightRate_pre, rightRate_post] = ...
            getPeriCueLickRates(R, getMask(trials,trialSpec), binWidth); % lickTimesAll(:,2) contains the right lick-times
        
        lickDiffs.preCue.(cue{j}).(rule{i}) = rightRate_pre - leftRate_pre; %Right minus left rate
        lickDiffs.postCue.(cue{j}).(rule{i}) = rightRate_post - leftRate_post; %Right minus left rate
    end
    
    % Pooled across sound cues for each rule
    trialSpec = {rule{i},'last20'};
    
    [leftRate_pre, leftRate_post] = getPeriCueLickRates(...
        L, getMask(trials,trialSpec), binWidth); % lickTimesAll(:,1) contains the left lick-times
    [rightRate_pre, rightRate_post] = getPeriCueLickRates(...
        R, getMask(trials,trialSpec), binWidth); % lickTimesAll(:,2) contains the right lick-times
    
    lickDiffs.preCue.all.(rule{i}) = rightRate_pre - leftRate_pre; %Right minus left rate
    lickDiffs.postCue.all.(rule{i}) = rightRate_post - leftRate_post; %Right minus left rate
    
end

%%------- INTERNAL FUNCTIONS -----------------------------------------------------------------------
function [ lickRate_pre, lickRate_post ] = getPeriCueLickRates( lickTimes, trialIdx, binWidth )

unit = 1/(sum(trialIdx)*binWidth); %1/(nTrials*seconds)
lt = [lickTimes{trialIdx,:}]; %Specified lick times
lickRate_pre  = sum(lt >= -binWidth & lt < 0)*unit;
lickRate_post = sum(lt > 0 & lt <= binWidth)*unit;