%%% start_dff_discrim_simpleplots()
%
% PURPOSE:  To plot group summary of cellular fluorescence data from a two-choice sensory
%               discrimination task.
%           
% AUTHORS: MJ Siniscalchi & AC Kwan 190321
%
% INPUT ARGS:   'expData', struct containing data dirs & experiment-specific params
%                   fields: 'sub_dir', 'logfile'
%               'dirs', struct containing directory structure.
%                   fields: 'data', 'analysis', 'summary'
%               'params', struct containing trial-averaging parameters
%                   fields: 'trigTime','xtitle','window','numBootstrapRepeat','CI','minNumTrial'
%                       notes: 'trigTime' specified as a fieldname from the struct 'trialData', 
%                               eg 'cueTimes'.
%
%--------------------------------------------------------------------------

function start_dff_discrim_simpleplots( expData, dirs, params ) %( expData, dirs, params )

tic;    %set clock to estimate how long this takes
setup_figprop;  %set up default figure plotting parameters

% Set trial-averaging parameters, if not specified in argument, 'params'
if nargin<3
    params = struct([]);
end

% Allow specification of subset of params; populate balance with defaults
default_names =     {'expIDs','trigTime','xtitle','window','numBootstrapRepeat','CI','minNumTrial'};
default_values =    {1:numel(expData), 'cueTimes', 'Time from sound cue (s)', (-3:0.5:7), 1000, 0.9, 0};
for ii = find(~isfield(params,default_names))
    params(1).(default_names{ii}) = default_values{ii}; %If param not present, use default.
end

%% Process data files ***FUTURE EDIT: allow specification in input args

for i = params.expIDs
    
    disp(['Processing file ' int2str(i) ' out of ' int2str(numel(expData)) '.']);
    
    % setup/create subdirectories to save analysis and figures
    savematpath = fullfile(dirs.analysis,expData(i).sub_dir);
    savefluofigpath = fullfile(dirs.analysis,expData(i).sub_dir,'figs-fluo');
    if ~exist(savefluofigpath,'dir')
        mkdir(savefluofigpath);
    end
    
    % load the saved behavioral analysis (from start_beh.m)
    cd(savematpath);
    load('beh.mat','trials','trialData');
    load('dff.mat','cells');
    
    cd(savefluofigpath);
    
    %% Plot event-aligned dF/F for each cell
    
    trigTime = trialData.(params.trigTime); %eg params.trigTime = 'cueTimes'
    
    % Plot specific cell IDs, or all cells
    if isfield(params,'cellIDs')
        cellList = params.cellIDs{i}; 
    else
        cellList = 1:numel(cells.dFF);
    end
    
    for j = cellList
        %% plot different choices in same panels
        psth_panel = []; %***FUTURE: initialize struct
        fieldname = cell([1,2]);
        for k = 1:4
            if k==1 %panel 1
                fieldname{1}={'sound','left','hit'}; col{1}='r'; linstyle{1}='-';
                fieldname{2}={'sound','right','hit'}; col{2}='b'; linstyle{2}='-';
            elseif k==2 %panel 2
                fieldname{1}={'sound','left','err'}; col{1}='r'; linstyle{1}=':';
                fieldname{2}={'sound','right','err'}; col{2}='b'; linstyle{2}=':';
            elseif k==3 %panel 3
                fieldname{1}={'sound','left','hit'}; col{1}='r'; linstyle{1}='-';
                fieldname{2}={'sound','left','err'}; col{2}='r'; linstyle{2}=':';
            elseif k==4 %panel 4
                fieldname{1}={'sound','right','hit'}; col{1}='b'; linstyle{1}='-';
                fieldname{2}={'sound','right','err'}; col{2}='b'; linstyle{2}=':';
            end
            for kk=1:numel(fieldname)
                trialMask = getMask(trials,fieldname{kk});
                psth_panel(k).sig{kk} = get_psth( cells.dFF{j}, cells.t, trigTime(trialMask), strjoin(fieldname{kk}), params );
                psth_panel(k).col{kk} = col{kk};
                psth_panel(k).linstyle{kk} = linstyle{kk};
            end
        end

        tlabel = ['Cell ' int2str(j)];
        plot_psth(psth_panel,tlabel,params.xtitle);
        print(gcf,'-dpng',['cell' int2str(j) '-choice']);
        saveas(gcf, ['cell' int2str(j) '-choice'], 'fig');
        close all;
    end
end
% plays sound when done
load train;
sound(y,Fs);

toc