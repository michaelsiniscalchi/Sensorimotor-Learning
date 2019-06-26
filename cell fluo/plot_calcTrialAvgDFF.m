%%% plotTrialAvgDFF()
%
% PURPOSE:  To plot group summary of cellular fluorescence data from a two-choice sensory
%               discrimination task.
%           
% AUTHORS: MJ Siniscalchi 190403
%
% INPUT ARGS:   
%
%--------------------------------------------------------------------------

% Create figures without displaying; display cellID in console...
% Get rid of 'psth_label' and replace with dataLabel = join(fieldnames,' ');

function figs = plot_trialAvgDFF( cells, trials, trigTime, params )

setup_figprop;  %set up default figure plotting parameters
if isfield(params,'cellList')
    cellList = params.cellList;
else
    cellList = 1:numel(cells.dFF);
end

%% Plot event-aligned dF/F for each cell
for j = cellList
    %% plot different choices in same panels
    input = []; %***FUTURE: initialize struct
    fieldname = cell([1,2]);
    cellID = cells.cellID{cellList(j)};
    for k = 1:4
        if k==1 %panel 1
            fieldname{1}={'left','hit'}; col{1}='r'; linstyle{1}='-';
            fieldname{2}={'right','hit'}; col{2}='b'; linstyle{2}='-';
        elseif k==2 %panel 2
            fieldname{1}={'left','err'}; col{1}='r'; linstyle{1}=':';
            fieldname{2}={'right','err'}; col{2}='b'; linstyle{2}=':';
        elseif k==3 %panel 3
            fieldname{1}={'left','hit'}; col{1}='r'; linstyle{1}='-';
            fieldname{2}={'left','err'}; col{2}='r'; linstyle{2}=':';
        elseif k==4 %panel 4
            fieldname{1}={'right','hit'}; col{1}='b'; linstyle{1}='-';
            fieldname{2}={'right','err'}; col{2}='b'; linstyle{2}=':';
        end
        for kk=1:numel(fieldname)
            %if regexp(fieldname{1}(1)) && regexp(fieldname{1}(2)), etc...
            %   input(k).sig{kk} = bootAvg.(fieldnames{i})
            %else, trialMask()... get_trialBoot()...end
            trialMask = getAllMask(trials,fieldname{kk});
            input(k).sig{kk} = get_trialBoot( cells.dFF{j}, cells.t, trigTime(trialMask), strjoin(fieldname{kk}), params );
            input(k).col{kk} = col{kk};
            input(k).linstyle{kk} = linstyle{kk};
        end
    end
    
    fig_title = ['Cell ' cellID];
    xLabel = 'Time from cue (s)'; 
    yLabel = 'Cellular Fluorescence (dF/F)';  
    figs(j) = plot_trialAvgTimeseries(input,fig_title,xLabel,yLabel);
   
end
% plays sound when done
load train;
sound(y,Fs);

toc