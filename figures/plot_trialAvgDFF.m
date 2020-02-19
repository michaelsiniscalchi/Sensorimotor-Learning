%%% plotTrialAvgDFF()
%
% PURPOSE:  To plot flexible summary of cellular fluorescence data from two-choice sensory
%               discrimination tasks.
%
% AUTHORS: MJ Siniscalchi 190912
%
% INPUT ARGS:
%
%--------------------------------------------------------------------------

function figs = plot_trialAvgDFF( bootAvg, cells, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters
if isfield(params,'cellIDs') && ~isempty(params.cellIDs)
    cellIdx = get_cellIndex(cells,params.cellIDs);
else
    fields = fieldnames(bootAvg);
    fields = fields(~strcmp(fields,'t'));
    cellIdx = 1:numel(bootAvg.(fields{1}));
end
figs = gobjects(numel(cellIdx),1); %Initialize
panels = params.panels; %Unpack for readability


%% Plot event-aligned dF/F for each cell

for i = 1:numel(cellIdx)
    
    % Assign specified signals to each structure in the array 'panels'
    idx = cellIdx(i); %Index in 'cells' structure for cell with corresponding cell ID
    disp(['Plotting trial-averaged dF/F for cell ' num2str(i) '/' num2str(numel(cellIdx)) '...']);
    for j = 1:numel(panels)
        for k = 1:numel(panels(j).trialSpec)
            
            trialSpec = panels(j).trialSpec{k}; %Trial specifier, eg {'left','hit','sound'}
            
            %Legend entries
            panels(j).legend_names{k} =  [upper(trialSpec{1}(1)) trialSpec{1}(2:end)]; %Leading trial specifier, all others should generally be fixed
            if params.verboseLegend
                %Remaining (fixed) trial conditions, if desired
                for kk = 2:numel(trialSpec) %
                    panels(j).legend_names{k} = [panels(j).legend_names{k} ' ' trialSpec{kk}];
                end
            end
            
            %Signal and confidence bounds
            panels(j).signal{k} = bootAvg.(strjoin(trialSpec,'_'))(idx).signal;
            panels(j).CI{k} = bootAvg.(strjoin(trialSpec,'_'))(idx).CI;
           
        end
        %Time axis
        panels(j).t = bootAvg.t;
    end
    
    ax_titles = {panels(:).title}'; %Specified in params.panels
    xLabel = params.xLabel;
    yLabel = params.yLabel;
    
    figs(i) = plot_trialAvgTimeseries(panels,ax_titles,xLabel,yLabel);
    figs(i).Name = ['cell' cells.cellID{idx} '_bootavg']; %Figure name
    figs(i).Position = [50,400,1800,500]; %LBWH
    figs(i).Visible = 'off';
    
end