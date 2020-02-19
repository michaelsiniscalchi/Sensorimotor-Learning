function fig = fig_lickDensity( trialData, trials, sessionID, params )

disp(sessionID);

edges = params.timeWindow(1):params.binWidth:params.timeWindow(2);
t = edges(1:end-1)+0.5*params.binWidth;

cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};
titles = {'Sound','Action left','Action right'};
ymax = 12; %Y-axis limit

setup_figprops([]);
fig = figure('Name',[sessionID ' - Lick density']);
fig.Position = [400 400 800 500]; %BLWH
tiledlayout(numel(cue),numel(rule));
for row = 1:numel(cue)
    for col = 1:numel(rule)
        %Extract specified data
        trialIdx = getMask(trials,{cue{row},rule{col},'last20'});
        lickL = histcounts([trialData.lickTimesLeft{trialIdx}],edges)/(sum(trialIdx)*params.binWidth); %Counts/trial/second
        lickR = histcounts([trialData.lickTimesRight{trialIdx}],edges)/(sum(trialIdx)*params.binWidth);
        
        %Plot lick densities
        idx = numel(rule)*(row-1)+col;
        ax(idx) = nexttile; hold on;
        plot(t,lickL,'Color',params.colors{1});  %Lick density, left
        plot(t,lickR,'Color',params.colors{2});  %Lick density, right
        plot([0,0],[0,ymax],':k','LineWidth',1); %Plot t0
        
        %Standardize plotting area
        ylim([0,ymax]); %0:10Hz
        xlim([edges(1),edges(end)]); %Trial window
        axis square;
        
        %Titles and axis labels
        if row==1
            title(titles{col}); %Title: rule
        end
        if col==1 && row==1
            ylabel({'Upsweep trials'; 'Lick density (Hz)'});
        elseif col==1
             ylabel({'Downsweep trials'; 'Lick density (Hz)'});
        end
        if row==2
            xlabel('Time from sound cue (s)');
        end
    end
end
