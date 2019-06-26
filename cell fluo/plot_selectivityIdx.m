%% plot_selectivityIdx
%
% PURPOSE:  To plot selectivity of cellular fluorescence for two non-overlapping subsets of trials
%           
% AUTHORS: MJ Siniscalchi 190516
%
% INPUT ARGS:   
%
%--------------------------------------------------------------------------

function figs = plot_selectivityIdx( cells, selectivity, params ) %eg (..., choiceSel, outcomeSel)

setup_figprop;  %set up default figure plotting parameters
if isfield(params,'cellIDs')
    cellIdx = get_cellIndex(cells,params.cellIDs);
else
    cellIdx = 1:numel(cells.dFF);
end

nPanels = numel(fieldnames(selectivity));

%% Plot selectivity with CI for each cell

for i = 1:numel(cellIdx)
    input = []; %***FUTURE: initialize struct
    j = cellIdx(i); %Index in 'cells' structure for cell with corrsponding cell ID
    
    for k = 1:nPanels
        if k==1 %panel 1
            type = 'choice';
            fieldname{1} = 'hit'; col{1} = 'c'; linstyle{1} = '-';
            fieldname{2} = 'err'; col{2} = [0.5,0.5,0.5]; linstyle{2}=':'; %Co-plot?
        elseif k==2 %panel 2
            type = 'outcome';
            fieldname{1} = 'left'; col{1}='r'; linstyle{1}='-';
            fieldname{2} = 'right'; col{2}='b'; linstyle{2}=':';
        end
        for kk = 1:numel(fieldname) %Number of overlayed plots in panel k
            input(k).sig{kk} = selectivity.(type).(fieldname{kk})(j);
%             input(k).sig{kk}.CI     = selectivity.(type).(fieldname{kk})(j).CI;
%             input(k).sig{kk}.t      = selectivity.(type).(fieldname{kk})(j).t;
            input(k).col{kk}        = col{kk};
            input(k).linstyle{kk}   = linstyle{kk};
        end
    end
    
    fig_title = ['Cell ' cells.cellID{j}]; %cells.cellID{idx} is already a char
    xLabel = 'Time from cue (s)'; 
    yLabel = 'Selectivity = 2*(AUROC-0.5)';  
    
    figs(i) = plot_trialAvgTimeseries(input,fig_title,xLabel,yLabel);
    figs(i).Name = ['cell' cells.cellID{j} '_selectivity']; %Figure name
    figs(i).Position = [50,400,1800,500]; %LBWH

end
% plays sound when done
load train;
sound(y,Fs);

toc