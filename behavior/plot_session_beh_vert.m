function plot_session_beh_vert(trialData,trials,blocks,tlabel,time_range)
% % plot_session_beh_vert %
%PURPOSE:   Plot flexibility task performance, vertical view
%AUTHORS:   AC Kwan 170515
%
%INPUT ARGUMENTS
%   trialData:    Structure generated by flex_getSessionData().
%   trials:       Structure generated by flex_getTrialMasks().
%   blocks:       Structure generated by flex_getBlockData().
%   tlabel:       Text to put as title of the plot
%   time_range:   Time in seconds to plot, e.g., [-2 6], around the cue

%if session too long, then split into multiple figures; how many trials per figure?
batchSize=100; 

nTrials=sum(blocks.nTrials);
numBatch=ceil(nTrials/batchSize);

for l=1:numBatch
    figure; hold on;
    title({tlabel;'{\color{blue}Upsweep} {\color[rgb]{0.5 0.8 1}Downsweep} {\color{green}Reward} {\color{magenta}Error} {\color{black}L Licks} {\color{red}R Licks}'});
    trial1=(l-1)*batchSize+1;
    trial2=trial1+batchSize-1;
    if trial2>nTrials
        trial2=nTrials;
    end
    
    for j=trial1:trial2
        refTime=trialData.cueTimes(j);
        
        %draw the cue
        if trials.upsweep(j)
            color='b';
        elseif trials.downsweep(j)
            color=[0.5 0.8 1];
        end
        eventTime=trialData.cueTimes(j);
        eventDur=2;
        p=fill([eventTime-refTime eventTime+eventDur-refTime eventTime+eventDur-refTime eventTime-refTime],[j-0.5 j-0.5 j+0.5 j+0.5],color);
        set(p,'Edgecolor',color);
        
        %draw the outcome
        if trials.hit(j)
            color='g';
        elseif trials.err(j)
            color='m';
        elseif trials.doublereward(j)
            color=[0 0.5 0];
        elseif trials.omitreward(j)
            color=[0.5 0 0.5];
        else
            color='w';        
        end
        eventTime=trialData.outcomeTimes(j);
        eventDur=3;
        p=fill([eventTime-refTime eventTime+eventDur-refTime eventTime+eventDur-refTime eventTime-refTime],[j-0.5 j-0.5 j+0.5 j+0.5],color);
        set(p,'Edgecolor',color);
        
        %draw licks
        ll=trialData.leftlickTimes{j};
        plot([ll; ll],j+[-0.5*ones(size(ll)); 0.5*ones(size(ll))],'k','LineWidth',2);
        rl=trialData.rightlickTimes{j};
        plot([rl; rl],j+[-0.5*ones(size(rl)); 0.5*ones(size(rl))],'r','LineWidth',2);
        
    end
    
    %plot a line where the rule switches are
    for j=1:length(blocks.firstTrial)
        plot([time_range(1) time_range(2)],(blocks.firstTrial(j)-0.5)*[1 1],'k');
    end
    
    xlim([time_range(1),time_range(2)]);
    ylim([trial1-1 trial1+batchSize]);
    set(gca, 'ydir','reverse')
    xlabel('Time (s)');
    ylabel('Trial');
    
    print(gcf,'-dpng',['session_vert-' int2str(l)]);    %png format
    %saveas(gcf, ['session_vert-' int2str(l)], 'fig');
    
end

end


