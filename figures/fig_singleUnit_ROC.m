
function figs = fig_singleUnit_ROC( decode, cells, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters

% Extract decoded behavioral variables
decodeType = fieldnames(decode);
decodeType = decodeType(~strcmp(decodeType,'t'));

%One figure per cell
nType = numel(decodeType);
nCells = numel(cells.cellID);
p = params.panels; %Unpack for readability
figs = gobjects(numel(decode.(decodeType{1}).selectivity),1);
for cellIdx = 1:nCells
    
    disp(['Generating figure from decoding analysis for Cell ' cells.cellID{cellIdx} '...']);
    
    figs(cellIdx) = figure('Name',['Cell ' cells.cellID{cellIdx} ' ROC']);
    figs(cellIdx).Position = [50 100 1800 800];
    figs(cellIdx).Visible = 'off';
    
    for typeIdx = 1:nType     %One row per decode type
        Y = decode.(decodeType{typeIdx}).selectivity{cellIdx};
        
        % Row 1: Plot bootstrapped selectivity and CI as a function of time
        ax(typeIdx) = subplot(2,nType,typeIdx); hold on;
        
        errorshade(decode.t, Y(2,:), Y(3,:), p(typeIdx).color, 0.2); %errorshade(Y,CI_low,CI_high,color,transparency)
        plot(decode.t,Y(1,:),'Color',p(typeIdx).color);
        plot([decode.t(1) decode.t(end)],[0 0],'k:','LineWidth',get(groot,'DefaultAxesLineWidth')); %Zero selectivity
        
        title(p(typeIdx).title);
        xlabel('Time from sound cue (s)');
        axis square tight;
        
        % Row 2: ROC curve
        %Find sample corresponding to peak modulation index
        ax(nType+typeIdx) = subplot(2,nType,nType+typeIdx); hold on;
        
        Y = Y(1,:);
        peak(typeIdx) = find(Y==max(abs(Y))|Y==-max(abs(Y)),1,'first'); %#ok<AGROW> %Peak modulation index
        plot(decode.(decodeType{typeIdx}).FPR{cellIdx}(:,peak(typeIdx)),...
            decode.(decodeType{typeIdx}).TPR{cellIdx}(:,peak(typeIdx)),'k-'); %ROC curve
        plot(decode.(decodeType{typeIdx}).FPR_shuffle{cellIdx}(:,peak(typeIdx)),...
            decode.(decodeType{typeIdx}).TPR_shuffle{cellIdx}(:,peak(typeIdx)),...
            ':','Color',[0.5 0.5 0.5]); %Shuffled ROC curve
        
        xlabel('False positive rate');
        axis square;
    end
        
    % Standardize scale of axes
    [low,high] = bounds([ax(1:nType).YLim]);
    for i = 1:nType
        ax(i).YLim = [nanmin(low) - 0.1*range([low;high]),...
            nanmax(high)+ 0.1*range([low;high])];
        plot(ax(i),[0 0],ax(i).YLim,'k-','LineWidth',get(groot,'DefaultAxesLineWidth')); %t0
    end
    
    %Legend & YLabels
    if decode.(decodeType{1}).AUC{cellIdx}(peak(1))>0.5
        legend(ax(nType+1),'ROC','Shuffle','Location','southeast'); %Positive class preference
    else
        legend(ax(nType+1),'ROC','Shuffle','Location','northwest'); %Negative class preference
    end
    ax(1).YLabel.String = 'Index = 2(AUC-0.5)';
    ax(nType+1).YLabel.String = 'True positive rate';
        
end