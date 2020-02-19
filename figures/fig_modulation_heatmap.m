function fig = fig_modulation_heatmap( decode, session_ID, cellID, params, sig_flag )

% Set up figure properties
setup_figprops(params.figs.mod_heatmap.fig_type)  %set up default figure plotting parameters

% Initialize figure
if nargin<5
    sig_flag = false;
    fig = figure('Name',['modulation_heatmap_' session_ID]);
else
    fig = figure('Name',['modulation_heatmap_' session_ID '_sigCells']);
end
fig.Position = [100,100,1600,800]; %LBWH
%fig.Visible = 'off';

%One subplot for each decode type
decodeType = fieldnames(decode);
decodeType = decodeType(~strcmp(decodeType,'t'));
for i = 1:numel(decodeType)
    
    %Extract selectivity traces and test statistical significance
    [sel_idx,~,isSelective,~,~] = ...
        get_selectivityTraces(decode,(decodeType{i}),params.decode);
    
    %Sort by preference then center-of-mass
    [sel_sorted,sig_sorted,cell_idx,~] = sort_selectivityTraces(sel_idx, isSelective, decode.t);
    if strcmp(sig_flag,'sig') && logical(sum(isSelective)) %Option: present only significantly modulated neurons
        sel_sorted = sel_sorted(sig_sorted,:);
        cell_idx = cell_idx(sig_sorted,:);
    elseif sig_flag
        sel_sorted = zeros(size(sel_sorted));
        cell_idx = [];
    end
    
    %Display results
    ax(i) = subplot(1,numel(decodeType),i);
    img = imagesc(sel_sorted);  hold on;
    img.XData = [decode.t(1) decode.t(end)];
    colormap(gca,params.figs.mod_heatmap.(decodeType{i}).cmap);
    
    %Colorbar
    clims = max(abs(img.CData(:)));
    caxis([-clims clims]); %Capture full range of magnitudes
    colorbar;
    
    %Label rows with cell indices
    ax(i).YTick = 1:numel(cell_idx);
    ax(i).YTickLabel = cellID(cell_idx);
    
    %Plot t0 
    axis tight;
    plot([0 0],ylim,'k:');
    
    %Title and axis labels
    txt = [upper(decodeType{i}(1)),decodeType{i}(2:end)];
    txt(txt=='_') = ' '; %Remove underscores from field names
    title(txt);
    xlabel(params.figs.mod_heatmap.xLabel);
       
end
 ax(1).YLabel.String = params.figs.mod_heatmap.yLabel;