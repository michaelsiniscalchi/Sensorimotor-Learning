function [ tables, structs ] = table_comparisons( stats )

%% DEFINE AND INITIALIZE COMMON VARIABLES
compStruct = struct('varName',[],'comparison',[],'diff',[],'p',[],'N',[],'testName',[],'stats',[]); %String 'stats' for F(df), t(df), W, etc.
mltCmpStruct = struct('varName',[],'comparison',[],'diff',[],'p',[]);

cellTypes = ["SST", "VIP", "PV", "PYR"]'; %Column vectors
ruleTypes = ["sound", "action"]';
outcomeTypes = ["hit","pErr","oErr","miss"]';

B = stats.behavior;
I = stats.imaging;
S = stats.selectivity;

% NOTES:    '{}' in first cell of var_spec reserved for 'cellTypes'.
%           '{}' in last cell of var_spec reserved for 'ruleTypes'.

%% FORMAL COMPARISONS: BEHAVIOR

% *** Collapsed across all Rules/Cell Types ***

% Mean Licks/s pre- vs post-cue
compStruct = addComparison(...
    compStruct, B.all, {"lickRates", ["preCue","postCue"],"completed"}, 'ttest'); %Report mean & sem

% Mean Licks/s post-cue for hit vs error trials
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","postCue",["hit","err"]}, 'ttest'); %Report mean & sem; **also examined pre-cue - very small (~0.1 Hz sig diff)

% Mean Licks/s pre-cue for sound vs action trials (Small overall (-) change in anticipatory licking)
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","preCue",["sound","action"]}, 'ttest'); %Report mean & sem

% Mean Licks/s pre- & post-cue for left vs right ports (Very mild overall Right-bias)
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","preCue",["lickL","lickR"]}, 'ttest'); %Report mean & sem
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","postCue",["lickL","lickR"]}, 'ttest'); %Report mean & sem

% Difference in Left vs Right Lick Rate across Block Types, Post-Cue (Clear differential response to cues across block types)
wsFactors = ["Cue","BlockType"]; %Order corresponds to multcompare syntax, eg, multcompare(stats,wsFactors(1),'By',wsFactors(2))
[compStruct, ~] = addComparison(compStruct,B.all,...
    {"lickDiffs","preCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
[compStruct, stats] = addComparison(compStruct,B.all,...
    {"lickDiffs","postCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
 %Significant interaction...only in Sound are upsweep vs downsweep significant
 mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName,wsFactors); 


%% FORMAL COMPARISONS: MODULATION

% Modulation by Choice: Proportion Selective & Mean Magnitude
%Null hypothesis for pSig: mean proportion of shuffled rows in each session that meet criterion (1 s @p<0.5)??

%Current trial, Sound Rule
[compStruct, stats] = addComparison(...
    compStruct,S,{"choice_sound",cellTypes,"pSig"},'anova1'); %Report mean & sem
mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName);

compStruct = addComparison(...
    compStruct,S,{"choice_sound",cellTypes,"selMag"},'anova1'); %Report mean & sem

%Current trial, Action Rule
[compStruct, stats] = addComparison(...
    compStruct,S,{"choice_action",cellTypes,"pSig"},'anova1'); %Report mean & sem
compStruct = addComparison(...
    compStruct,S,{"choice_action",cellTypes,"selMag"},'anova1'); %Report mean & sem

%Prior trial
[compStruct, stats] = addComparison(...
    compStruct,S,{"prior_choice",cellTypes,"pSig"},'anova1'); %Report mean & sem
compStruct = addComparison(...
    compStruct,S,{"prior_choice",cellTypes,"selMag"},'anova1'); %Report mean & sem

% Modulation by Outcome: Proportion Selective & Mean Magnitude
[compStruct, stats] = addComparison(...
    compStruct,S,{"outcome",cellTypes,"pSig"},'anova1'); %Report mean & sem
compStruct = addComparison(...
    compStruct,S,{"outcome",cellTypes,"selMag"},'anova1'); %Report mean & sem
for i = 1:numel(cellTypes)
    compStruct = addComparison(...
        compStruct,S,{"outcome",cellTypes(i),["pPrefPos","pPrefNeg"]},'ttest'); %Report mean & sem
end


%% RETURN DATA STRUCTURES AS TABLES

structs.comparisons = compStruct;
tables.comparisons = struct2table(compStruct);
disp(tables.comparisons);

structs.multiple_comparisons = mltCmpStruct;
tables.multiple_comparisons = struct2table(mltCmpStruct);
disp(tables.multiple_comparisons);


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function [data_struct, stats] = addComparison( data_struct, stats_struct, comp_spec, test_name, wsFactors )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'comp_spec', A cell array specifying hierarchy of fields containing variables for comparison.
%
%---------------------------------------------------------------------------------------------------

%% Fixed parameters
alpha = 0.5; %Alpha, threshold parameter for hypothesis testing

%% Argument Check
if nargin<5
    wsFactors = []; %Can be omitted unless repeated measures ANOVA is needed.
end

%% Perform hypothesis tests

% Extract Data for Descriptive Stats or Comparisons
[ data, group ] = getStatsData( stats_struct, comp_spec);

% Perform Statistical Comparisons
[ stats, p, stats_str ] = compareGroups( test_name, data, group, wsFactors );

% Append Additional Fields from 'dataStruct'

%Variable name
varName = strjoin([comp_spec{cellfun(@length,comp_spec)==1}],'_');

%Comparison
comparison = comp_spec{cellfun(@length,comp_spec)>1}; %For 1-way comparisons, the unique cell containing multiple fields
if any(strcmp(comparison,"SST"))
    comparison = "Cell types";
elseif ~isempty(wsFactors)
    comparison = strjoin(wsFactors);
else, comparison = strjoin(comparison);
end

%Estimated effect size
diff = NaN;
if isfield(stats,'diff')
    diff = stats.diff;
end

%Sample size
N = cellfun(@length,data');
if numel(unique(N))==1
    N = unique(N);
end

% Concatenate with Existing Data Structure
idx = length(data_struct)+1;
data_struct(idx,1) = struct(...
    'varName',varName,'comparison',comparison,'diff',num2str(diff),...
    'p',num2str(p),'N',num2str(N),'testName',test_name,'stats',stats_str); %Enforce column vector

% Remove empty rows 
idx = ~cellfun(@isempty,{data_struct.varName}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
data_struct = data_struct(idx);