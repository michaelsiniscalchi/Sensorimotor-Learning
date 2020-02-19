function [ calculate, summarize, figures, mat_file, params ] = params_RuleSwitching(dirs,expData)

%% CALCULATE OR RE-CALCULATE RESULTS
calculate.behavior              = false;
calculate.stack_info            = false;
calculate.combined_data         = false;  %Combine relevant behavioral and imaging data in one MAT file ; truncate if necessary
calculate.cellF                 = false; %Extract cellf and neuropilf from ROIs, excluding overlapping regions and extremes of the FOV
calculate.dFF                   = false; %Calculate dF/F, with optional neuropil subtraction
calculate.align_signals         = false; %Interpolate dF/F and align to behavioral events
calculate.trial_average_dFF     = false; %dF/F averaged over specified subsets of trials
calculate.decode_single_units   = true; %ROC/Selectivity for choice, outcome and rule
calculate.transitions           = false; %Changes in dF/F over each block; 

calculate.fluorescence = false;
if any([calculate.cellF, calculate.dFF, calculate.align_signals, calculate.trial_average_dFF,...
		calculate.decode_single_units, calculate.transitions])
	calculate.fluorescence = true;
end

%% SUMMARIZE RESULTS
summarize.behavior              = false;
summarize.imaging               = false; 
summarize.selectivity           = true;
summarize.transitions           = false;

summarize.stats                     = true; %Descriptive stats; needed for all summary plots
summarize.comparisons               = false; %Formal comparisons ***PROBABLY NIX***
summarize.table_experiments         = false;
summarize.table_descriptive_stats   = false;
summarize.table_comparative_stats   = false;

%% PLOT RESULTS

% Behavior
figures.raw_behavior                    = false;
figures.lick_density                    = false;
% Imaging %***REDO Overnight***
figures.FOV_mean_projection             = false;
figures.timeseries                      = false; %Plot all timeseries for each session
% Combined
figures.trial_average_dFF               = false;  %Overlay traces for distinct choices, outcomes, and rules (CO&R)
figures.decode_single_units             = false;
figures.heatmap_modulation_idx          = false;  %Heatmap of selectivity idxs for COR for each session
figures.transitions                     = false; 
% Summary
figures.summary_behavior                = false; %Summary of descriptive stats, eg, nTrials and {trials2crit, pErr, oErr} for each rule
figures.summary_lick_density            = false;
figures.summary_periswitch_performance  = false;
figures.summary_modulation_heatmap      = false; %Heatmap for each celltype, all sessions, one figure each for CO&R
figures.summary_modulation				= false; %Bar/line plots of grouped selectivity results for comparison
figures.summary_transitions             = false;

% Validation
figures.validation_ITIs                 = false;
figures.validation_ROIs                 = false;
figures.validation_alignment            = false;

%% PATHS TO SAVED DATA
%By experiment
mat_file.behavior       = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'behavior.mat');
mat_file.stack_info     = @(idx) fullfile(dirs.data,expData(idx).sub_dir,'stack_info.mat');
mat_file.cell_fluo      = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'cell_fluo.mat');
mat_file.img_beh        = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'img_beh.mat');
mat_file.results        = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'results.mat');
%Aggregated
mat_file.summary.behavior       = fullfile(dirs.summary,'behavior.mat');
mat_file.summary.imaging        = fullfile(dirs.summary,'imaging.mat');
mat_file.summary.selectivity    = fullfile(dirs.summary,'selectivity.mat');
mat_file.summary.transitions    = fullfile(dirs.summary,'transitions.mat');
mat_file.stats                  = fullfile(dirs.summary,'summary_stats.mat');
mat_file.validation             = fullfile(dirs.summary,'validation.mat');
%Figure Data
mat_file.figData.fovProj        = fullfile(dirs.figures,'FOV mean projections','figData.mat'); %Directory created in code block for figure

%% HYPERPARAMETERS FOR ANALYSIS

% Behavior
params.behavior.timeWindow = [-2 5]; 
params.behavior.binWidth = 0.1; %In seconds; for lick density plots
params.behavior.preCueBinWidth = 2; %In seconds; for lick density plots

% Cellular fluorescence calculations
params.fluo.exclBorderWidth     = 5; %For calc_cellF: n-pixel border of FOV to be excluded from analysis

% Interpolation and alignment
params.align.trigTimes  = 'cueTimes';
params.align.interdt    = 0.05; %Query intervals for interpolation in seconds (must be <0.5x original dt; preferably much smaller.)
params.align.window     = params.behavior.timeWindow; %Also used for bootavg, etc.

% Trial averaging
params.bootAvg.window       = params.behavior.timeWindow;
params.bootAvg.dsFactor     = 5; %Downsample from interpolated rate of 1/params.interdt
params.bootAvg.nReps        = 1000; %Number of bootstrap replicates
params.bootAvg.CI           = 90; %Confidence interval as decimal
params.bootAvg.trialSpec    =...
	{...
	{'left' 'hit' 'sound' 'last20'},...
	{'right' 'hit' 'sound' 'last20'};... %Decode choice in Sound trials
	
	{'left' 'hit' 'action' 'last20'},...
	{'right' 'hit' 'action' 'last20'};... %Decode choice in Action trials
    
    {'priorLeft' 'priorHit' 'sound' 'last20'},...
	{'priorRight' 'priorHit' 'sound' 'last20'};... %Decode prior choice in Sound trials
	
	{'hit','priorHit'},...
	{'err','priorHit'};... %Decode outcome
	
	{'sound' 'left' 'priorLeft' 'hit' 'last20'},... %Decode rule with choice/outcome fixed
	{'actionL' 'left' 'priorLeft' 'hit' 'last20'};... 
	
	{'sound' 'right' 'priorRight' 'hit' 'last20'},...
	{'actionR' 'right' 'priorRight' 'hit' 'last20'};...
	}; %Spec for each trial subset for comparison (conjunction of N fields from 'trials' structure.)

% Single-unit decoding
params.decode.decode_type     = {'choice_sound','choice_action','prior_choice','outcome','rule_SL','rule_SR'}; %MUST have same number of elements as rows in trialSpec. Eg, = {'choice','outcome','rule_SL','rule_SR'}
params.decode.trialSpec       = params.bootAvg.trialSpec; %Spec for each trial subset for comparison (conjunction of N fields from 'trials' structure.)
params.decode.dsFactor        = params.bootAvg.dsFactor; %Downsample from interpolated rate of 1/params.interdt
params.decode.nReps           = params.bootAvg.nReps; %Number of bootstrap replicates
params.decode.nShuffle        = 1000; %Number of shuffled replicates
params.decode.CI              = params.bootAvg.CI; %Confidence interval as percentage
params.decode.sig_method      = 'shuffle';  %Method for determining chance-level: 'bootstrap' or 'shuffle'
params.decode.sig_duration    = 1;  %Number of consecutive seconds exceeding chance-level

% Transition analyses
params.transitions.window           = params.behavior.timeWindow; %Time to be considered within trial
params.transitions.nTrialsPreSwitch = 10; %Number of trials from origin and destination rules to average for comparison with transition trial(i)
params.transitions.cell_subset      = 'all'; %'significant' or 'all'; denotes whether only significantly rule-modulated cells are used
params.transitions.CI               = params.bootAvg.CI; %Threshold for significant modulation; include only significantly modulated cells
params.transitions.sig_method       = params.decode.sig_method;  %Method for determining chance-level: 'bootstrap' or 'shuffle'
params.transitions.sig_duration     = params.decode.sig_duration;  %Number of consecutive seconds exceeding chance-level
params.transitions.stat             = 'Rho'; %Statistic to use as similarity measure: {'R','Rho','Cs'}
params.transitions.nBins            = 10; %Number of bins for aggregating evolution of activity vectors

%% SUMMARY STATISTICS
params.stats.analysis_names = {'behavior','imaging','selectivity'};

%% FIGURES: COLOR PALETTE FROM CBREWER
% Color palette from cbrewer()
c = cbrewer('qual','Paired',10);
colors = {'red',c(6,:),'red2',c(5,:),'blue',c(2,:),'blue2',c(1,:),'green',c(4,:),'green2',c(3,:),...
    'purple',c(10,:),'purple2',c(9,:),'orange',c(8,:),'orange2',c(7,:)};
% Add additional colors from Set1 and RGB
c = cbrewer('qual','Set1',9);
colors = [colors {'pink',c(8,:),'black',[0,0,0],'gray',c(9,:)}];
cbrew = struct(colors{:}); %Merge palettes
clearvars colors

%Define color codes for cell types, etc.
cellColors = {'SST',cbrew.orange,'SST2',cbrew.orange2,'VIP',cbrew.green,'VIP2',cbrew.green2,...
    'PV',cbrew.purple,'PV2',cbrew.purple2,'PYR',cbrew.blue,'PYR2',cbrew.blue2}; 
ruleColors = {'sound',cbrew.black,'sound2',cbrew.gray,'action',cbrew.red,'action2',cbrew.red2}; %{Sound,Action}
dataColors = {'data',cbrew.gray};
colors = struct(cellColors{:},ruleColors{:},dataColors{:});

%% FIGURE: MEAN PROJECTION FROM EACH FIELD-OF-VIEW
params.figs.fovProj.calcProj        = true; %Calculate or re-calculate projection from substacks for each trial (time consuming).
params.figs.fovProj.blackLevel      = 20; %As percentile
params.figs.fovProj.whiteLevel      = 99.7; %As percentile
params.figs.fovProj.overlay_ROIs    = false; %Overlay outlines of ROIs
params.figs.fovProj.overlay_npMasks = false; %Overlay outlines of neuropil masks
params.figs.fovProj.expIDs          = [];
% params.figs.fovProj.expIDs = {...
%     '180831 M55 RuleSwitching';...
%     '181003 M52 RuleSwitching'};

% For plotting only selected cells
params.figs.fovProj.cellIDs{numel(expData)} = []; %Initialize
% params.figs.fovProj.cellIDs(restrictExpIdx({expData.sub_dir},params.figs.fovProj.expIDs)) = {... % One cell per session, containing cellIDs
% {'140','141','142','143','144'};
% {'001','002','003','004','005','006','007','008','009','010'}};

%% FIGURE: RAW BEHAVIOR
params.figs.behavior.window = params.behavior.timeWindow; 
params.figs.behavior.colors = {cbrew.red, cbrew.blue, cbrew.green};

%% FIGURE: LICK DENSITY IN VARIED TRIAL CONDITIONS
params.figs.lickDensity.timeWindow = params.behavior.timeWindow; %For lick density plots
params.figs.lickDensity.binWidth = params.behavior.binWidth; 
params.figs.lickDensity.colors = {cbrew.red, cbrew.blue};

%% FIGURE: PERFORMANCE CURVES SURROUNDING RULE SWITCH
params.figs.perfCurve.outcomes = {'hit','pErr','oErr','miss'};
params.figs.perfCurve.colors = {cbrew.green,cbrew.pink,cbrew.pink,cbrew.gray}; %Hit,pErr,oErr,Miss
params.figs.perfCurve.LineStyle = {'-','-',':','-'};

%% FIGURE: CELLULAR FLUORESCENCE TIMESERIES FOR ALL NEURONS
params.figs.timeseries.expIDs           = [];
params.figs.timeseries.cellIDs          = [];
% params.figs.timeseries.expIDs           = {...
%     '180831 M55 RuleSwitching';...
%     '181003 M52 RuleSwitching'};
% params.figs.timeseries.cellIDs          = {...
%     {'140','141','142','143','144'};
%     {'001','002','003','004','005','006','007','008','009','010'}};

params.figs.timeseries.trialMarkers     = false;
params.figs.timeseries.trigTimes        = 'cueTimes'; %'cueTimes' or 'responseTimes'
params.figs.timeseries.ylabel_cellIDs   = true;
params.figs.timeseries.spacing          = 10; %Spacing between traces in SD 
params.figs.timeseries.FaceAlpha        = 0.2; %Transparency for rule patches
params.figs.timeseries.LineWidth        = 0.5; %LineWidth for dF/F
params.figs.timeseries.Color            = struct('red',cbrew.red, 'blue', cbrew.blue); 

%% FIGURE: TRIAL-AVERAGED CELLULAR FLUORESCENCE

% -------Trial Averaging: choice, outcome, and rule-------------------------------------------------

params.figs.bootAvg.cellIDs              = [];
params.figs.bootAvg.xLabel               = 'Time from sound cue (s)';  % XLabel
params.figs.bootAvg.yLabel               = 'Cellular Fluorescence (dF/F)';
params.figs.bootAvg.verboseLegend        = false;

%Specify array 'p' containing variables and plotting params for each figure panel:
trialSpec = params.bootAvg.trialSpec;
for i=1:size(params.bootAvg.trialSpec,1)
	p(i).trialSpec  = {trialSpec{i,1},trialSpec{i,2}}; %#ok<AGROW> %Refer to params.bootAvg.trialSpec
end
p(1).title      = 'Choice (sound rule)';
p(1).color      = {cbrew.red,cbrew.blue}; %Choice: left/hit/sound vs right/hit/sound
p(1).lineStyle  = {'-','-'};
p(2).title      = 'Choice (action rule)';
p(2).color      = {cbrew.red,cbrew.blue}; %Choice: left/hit/sound vs right/hit/sound
p(2).lineStyle  = {'-','-'};
p(3).title      = 'Prior choice';
p(3).color      = {cbrew.red,cbrew.blue}; %Choice: left/hit/sound vs right/hit/sound
p(3).lineStyle  = {'-','-'};
p(4).title      = 'Outcome';
p(4).color      = {cbrew.green,cbrew.pink}; %Outcome: hit/priorHit vs err/priorHit
p(4).lineStyle  = {'-','-'};
p(5).title      = 'Rule (left choice)';
p(5).color      = {'k',cbrew.red}; %Rule: left/upsweep/sound vs left/upsweep/actionL
p(5).lineStyle  = {'-','-'};
p(6).title      = 'Rule (right choice)';
p(6).color      = {'k',cbrew.blue}; %Rule: right/downsweep/sound vs right/downsweep/actionR
p(6).lineStyle  = {'-','-'};

params.figs.bootAvg.panels = p;
clearvars p

%% FIGURE: MODULATION INDEX: CHOICE, OUTCOME, AND RULE

% Single-unit plots
params.figs.decode_single_units.fig_type             = 'singleUnit';
params.figs.decode_single_units.cellIDs              = [];

%Specify array 'p' containing variables and plotting params for each figure panel:
p(1).title      = 'Choice (sound rule)';
p(1).color      = 'k';
p(2).title      = 'Choice (action rule)';
p(2).color      = 'k';
p(3).title      = 'Prior choice';
p(3).color      = 'k';
p(4).title      = 'Outcome';
p(4).color      = cbrew.green;
p(5).title      = 'Rule (left choice)';
p(5).color      = cbrew.red;
p(6).title      = 'Rule (right choice)';
p(6).color      = cbrew.blue;
params.figs.decode_single_units.panels = p;
clearvars p;

% Heatmaps
params.figs.mod_heatmap.fig_type        = 'heatmap';
params.figs.mod_heatmap.xLabel          = 'Time from sound cue (s)';  % XLabel
params.figs.mod_heatmap.yLabel          = 'Cell ID (sorted)';
params.figs.mod_heatmap.datatips        = true;  %Draw line with datatips for cell/exp ID

params.figs.mod_heatmap.choice_sound.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.choice_sound.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.choice_action.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.choice_action.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.prior_choice.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.prior_choice.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.outcome.cmap    = cbrewer('div', 'PiYG', 256);
params.figs.mod_heatmap.outcome.color   = c(3,:);

params.figs.mod_heatmap.rule_SL.cmap    = [flipud(cbrewer('seq','Reds',128));cbrewer('seq','Greys',128)];
params.figs.mod_heatmap.rule_SL.color   = c(1,:);

params.figs.mod_heatmap.rule_SR.cmap    = [flipud(cbrewer('seq','Blues',128));cbrewer('seq','Greys',128)];
params.figs.mod_heatmap.rule_SR.color   = c(2,:);

%% FIGURE: NEURAL TRANSITIONS

params.figs.transitions.Color = {cbrew.black, cbrew.red, cbrew.gray};

%% SUMMARY FIGURE: BEHAVIORAL STATISTICS

%***TODO: RECODE COLOR SPECS based on color scheme in struct 'colors'***
params.figs.summary_behavior.ruleColors = {[colors.sound;colors.sound2],[colors.action;colors.action2]}; %{Sound,Action}
params.figs.summary_behavior.cellColors = {colors.SST,colors.VIP,colors.PV,colors.PYR}; %{SST,VIP,PV,PYR}

%% SUMMARY FIGURE: MODULATION INDEX-----------------------------------------------

% ---Selectivity plots------------------------------------------------------------------------------

%Specify array 'f' containing variables and plotting params for each figure:
f(1).fig_name   = 'Mean_Selectivity_all';
f(1).var_name   = {'selIdx','selIdx_t'};

f(2).fig_name   = 'Mean_Selectivity_sig';
f(2).var_name   = {'sigIdx','sigIdx_t'};

f(3).fig_name   = 'Mean_Magnitude_all'; 
f(3).var_name   = {'selMag','selMag_t'};

f(4).fig_name   = 'Mean_Magnitude_sig'; 
f(4).var_name   = {'sigMag','sigMag_t'};

f(5).fig_name   = 'Proportion_Selective';
f(5).var_name   = {'pSig', 'pSig_t'};

params.figs.summary_modulation.figs = f;

params.figs.summary_modulation.titles =...
    {'Choice (sound rule)','Choice (action rule)','Prior choice',...
    'Outcome','Rule (left choice)','Rule (right choice)'};

%Appearance
params.figs.summary_modulation.barWidth = 0.5;
params.figs.summary_modulation.colors = colors; %Struct contains, eg, colors.SST, colors.SST2, etc.

% ---Preference plot------------------------------------------------------------------------------

params.figs.summary_preference.titles = params.figs.summary_modulation.titles; %Titles (cell array)
%params.figs.summary_preference.dispersion = 'SEM'; %Bars with error bars
params.figs.summary_preference.dispersion = 'IQR'; %Boxes with whiskers

%Appearance
params.figs.summary_preference.lineWidth = 2;
params.figs.summary_preference.boxWidth = 0.2;
params.figs.summary_preference.boxColors = colors;
c = cbrewer('qual','Paired',10);
params.figs.summary_preference.colors = {c([8,4,10,2],:),c([7,3,9,1],:)}; %Swap order


%% SUMMARY FIGURE: NEURAL TRANSITION ANALYSIS 

p(1).cellTypes      = {'SST','VIP','PV','PYR'};
p(1).transTypes     = {'actionR_sound','sound_actionL','actionL_sound','sound_actionR'}; %Order should be S-A-S-A for color order

p(2).cellTypes      = {'SST','VIP','PV','PYR'};
p(2).transTypes     = {'sound','action'}; 

p(3).cellTypes      = {'all'};
p(3).transTypes     = {'sound','action'};  

for i=1:numel(p)
p(i).stat = params.transitions.stat;
end

params.figs.summary_transitions = p;
clearvars p;

% Neurobehavioral switch
p.color = colors;
p.useChangePt = true; %Use behavioral changepouint analysis; use nTrials-20 if false
params.figs.summary_changePoints = p;
clearvars p;
