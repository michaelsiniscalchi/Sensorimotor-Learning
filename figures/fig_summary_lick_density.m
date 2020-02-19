function fig = fig_summary_lick_density( behavior, cellType, params )

%Extract data for plotting: lick density as f(t)
D = behavior.(cellType).lickDensity; %Extract cell-type specific data
edges = params.timeWindow(1):params.binWidth:params.timeWindow(2);
t = edges(1:end-1)+0.5*params.binWidth;

%Set up panels for plotting
direction = {'left','right'};
cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};
titles = {'Sound','Action left','Action right'};

setup_figprops([]);
fig = figure('Name',['Lick density summary - ' cellType]);
fig.Position = [400 400 870 600]; %BLWH  [400 396 872 600]
tiledlayout(numel(cue),numel(rule),'TileSpacing','none','Padding','none');
ax = gobjects(numel(cue)*numel(rule),1);
ymax = 12; %Y-axis limit

%Plot lick density as f(t)
for row = 1:numel(cue)
    for col = 1:numel(rule)
        
        idx = numel(rule)*(row-1)+col;
        ax(idx) = nexttile; hold on;
        for i = 1:numel(direction)
            %Extract specified data
            data = D.(direction{i}).(cue{row}).(rule{col}); %Counts/trial/second
            %Plot lick densities
            CI = data.mean + [-data.sem; data.sem];
            errorshade(t,CI(1,:),CI(2,:),params.colors{i},0.2); % errorshade(X,CI_low,CI_high,color,transparency)
            plot(t,data.mean,'Color',params.colors{i});  %Lick density, {left,right}
        end
        plot([0,0],[0,ymax],':k','LineWidth',1); %Plot t0
        
        %Standardize plotting area
        ylim([0,ymax]); %[0,12] Hz
        xlim([edges(1),edges(end)]); %Trial window
        axis square;
        
        %Titles and axis labels
        if row==1
            title(titles{col}); %Title: rule
            ax(idx).XTickLabel = [];
        else
            xlabel('Time from sound cue (s)');
        end
        if col==1 && row==1
            ylabel({'Upsweep trials'; 'Lick density (Hz)'});
        elseif col==1
             ylabel({'Downsweep trials'; 'Lick density (Hz)'});
        else
            ax(idx).YTickLabel = [];
        end
        
    end
end
