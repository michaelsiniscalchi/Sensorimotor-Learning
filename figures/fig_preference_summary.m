function fig = fig_summary_preference( stats_selectivity, time, params )

setup_figprops('singleUnit');

%Four subplots: one for each decode type
S = stats_selectivity;
decodeType = fieldnames(S);
cellType = fieldnames(S.(decodeType{1}));


    fig = figure('Name',params.figs(i).fig_name);
    var_name = params.figs(i).var_name;
    for j = 1:numel(var_name)
		clearvars var Mean SEM Y X
	
        for k = 1:numel(decodeType)
            %One plot for each decode type
            ax(k) = subplot(numel(var_name),4,k+4*(j-1)); hold on; %#ok<AGROW>
            %One bar for each cell type
            for kk=1:numel(cellType)
                var = S.(decodeType{k}).(cellType{kk}).(var_name{j});
                Mean(kk,:) = var.mean;
                SEM(kk,:) = var.sem;
                Y{kk} = var.data;
                X{kk} = kk*ones(size(Y{kk}));
            end

            if size(var.data,2)==1 
                %Bar chart with overlayed data by session
                bar(Mean,'FaceColor','none','EdgeColor','flat','LineWidth',2,'CData',params.colors);
                for kk=1:numel(cellType)
                    plot(X{kk},Y{kk},'o','Color',[0.5 0.5 0.5],'LineWidth',1);
                end
                ax(k).XTick = 1:numel(cellType); %Bar chart: titles and labels
                ax(k).XTickLabels = cellType;
            else
                %Line plot with SEM
                for kk=1:numel(cellType)
                    CI = Mean(kk,:) + [SEM(kk,:); -SEM(kk,:)];
                    errorshade(time,CI(1,:),CI(2,:),params.colors(kk,:),0.2);
                    plot(time,Mean(kk,:),'-','Color',params.colors(kk,:));
                end
                xlabel('Time from sound cue');
            end
            %Get ylims for later standardization
            axis square;
            ylims(k,:) = ylim;
                                   
            if j==1 %Labels for top row
                title_str = [upper(decodeType{k}(1)), decodeType{k}(2:end)];
                title_str(title_str=='_') = ' ';
                ax(k).Title.String = title_str;
            end
        end
        %Set YLabel
        ax(1).YLabel.String = getYLabel(var_name{j});
        %Set YLims and plot t0 and y = 0
        ylim(ax,[min(ylims(:)) max(ylims(:))]);
        if size(var.data,2)>1 %If line
            for k = 1:numel(cellType)
                plot(ax(k),[0 0],[min(ylim) max(ylim)],':k','LineWidth',0.5);
            end
        
        end
        if min(ylim)<0 %If line
            for k = 1:numel(cellType)
                plot(ax(k),[min(xlim) max(xlim)],[0 0],'-k','LineWidth',0.5);
            end
        end
    end

