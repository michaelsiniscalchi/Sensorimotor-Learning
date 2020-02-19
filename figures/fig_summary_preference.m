function fig = fig_summary_preference( stats_selectivity, time, params )

setup_figprops('timeseries');

%Four subplots: one for each decode type
S = stats_selectivity;
decodeType = fieldnames(S);
nDecode = numel(decodeType);
cellType = fieldnames(S.(decodeType{1}));

%Initialize figure
fig = figure('Name','Proportion_Pref_classX','Position',[10 500 1900 400]);
ax = gobjects(numel(decodeType),1);
lineWidth = params.lineWidth;
boxWidth = params.boxWidth;

var_name = {'pPrefPos','pPrefNeg'};
for i = 1:nDecode
    %One plot for each decode type
    ax(i) = subplot(1,nDecode,i); hold on; %#ok<AGROW>
    %One pair of bars for each cell type
    for j=1:numel(cellType)
        for k = 1:numel(var_name)
            var = S.(decodeType{i}).(cellType{j}).(var_name{k});
            Mean(j,k) = var.mean;
            SEM(j,k) = var.sem;
            Y{j,k} = var.data;
%             Median{j,k} = var.median;
%             IQR{j,k} = var.IQR;
        end
    end
    
    %Bar chart with overlayed data by session
    if strcmp(params.dispersion,'SEM')
        b = bar(Mean,'FaceColor','flat','EdgeColor','flat'); hold on;
        for k = 1:numel(b)
            b(k).CData = params.colors{k};
            bar_center(:,k) = b(k).XEndPoints;
        end
        
        %Error bars
        for j=1:numel(cellType)
            for k = 1:numel(var_name)
                errorbar(bar_center(j,k),Mean(j,k),SEM(j,k),...
                    'Color',params.colors{k}(j,:),'LineWidth',lineWidth,'CapSize',0);
            end
        end

    elseif strcmp(params.dispersion,'IQR')
        X = 1:numel(cellType);
        offset = 0.5*boxWidth + 0.05;
        for j = X
            %Box plot with 95% whiskers and median as line
            % Left box in group
            plot_basicBox(X(j)-offset, Y{j,1},...
                boxWidth, lineWidth, params.boxColors.(cellType{j}));
            % Right box in group
            plot_basicBox(X(j)+offset, Y{j,2}, ...
                boxWidth, lineWidth, params.boxColors.([cellType{j},'2']));
        end
    end
    
    ax(i).XTick = 1:numel(cellType); %Bar chart: titles and labels
    ax(i).XTickLabels = cellType;
    
    %Get ylims for later standardization
    axis square;
    ylims(i,:) = ylim; %Store ylims to create uniform axes for all vars later...
    
    %Title
    if isfield(params,'titles') && ~isempty(params.titles)
        ax(i).Title.String = params.titles{i};
    else %Use decode fieldnames
        title_str = [upper(decodeType{i}(1)), decodeType{i}(2:end)];
        title_str(title_str=='_') = ' ';
        ax(i).Title.String = title_str;
    end
    
    
end

%Set YLabel & YLims
ax(1).YLabel.String = 'Proportion pref. +/- class';
ylim(ax,[min(ylims(:)) max(ylims(:))]);
xlim(ax,[0.5 numel(cellType)+0.5]); %0.5 unit margins on each side