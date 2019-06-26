function fig = plot_lickrate_overlay(input)
% % plot_lickrate_byTrialType %
%PURPOSE:   Plot lick rates for different trial types
%AUTHORS:   AC Kwan 170518; modified by MJ Siniscalchi 190625
%
%INPUT ARGUMENTS
%   input:        Structure generated by get_lickrate_byTrialType().
%   tlabel:       Text to put as title of the plot.

%%
% if called from single-session analysis, input is a struct
% if called from summary analysis, input is a cell array
% here convert everything to a cell array first
if ~iscell(input)
    temp = input;
    clear input;
    input{1} = temp;
end

% load from the cell array
edges=input{1}.edges;
trialType=input{1}.trialType;
    
for j=1:numel(input)
    for l=1:numel(trialType)
        if j==1     %first time, load the array
            up_leftTimes{l}=input{j}.up_leftTimes{l};
            up_rightTimes{l}=input{j}.up_rightTimes{l};
            down_leftTimes{l}=input{j}.down_leftTimes{l};
            down_rightTimes{l}=input{j}.down_rightTimes{l};    
            
            u_rewardTimes{l}=input{j}.up_rewardTimes{l};
            d_rewardTimes{l}=input{j}.down_rewardTimes{l};
        else        %otherwise, append
            up_leftTimes{l}=[(up_leftTimes{l}) input{j}.up_leftTimes{l}];
            up_rightTimes{l}=[(up_rightTimes{l}) input{j}.up_rightTimes{l}];
            down_leftTimes{l}=[(down_leftTimes{l}) input{j}.down_leftTimes{l}];
            down_rightTimes{l}=[(down_rightTimes{l}) input{j}.down_rightTimes{l}];

            u_rewardTimes{l}=[u_rewardTimes{l}; input{j}.up_rewardTimes{l}];
            d_rewardTimes{l}=[d_rewardTimes{l}; input{j}.down_rewardTimes{l}];        
        end
    end
end

%% calculate mean and sem
edges=edges(1:end-1)+nanmean(diff(edges))/2;   %plot using the center of the histogram bins

u_lTimes=nan(numel(edges),numel(trialType)); % of choosing left
u_rTimes=nan(numel(edges),numel(trialType)); % of choosing right
d_lTimes=nan(numel(edges),numel(trialType)); % of choosing left
d_rTimes=nan(numel(edges),numel(trialType)); % of choosing right
for j=1:numel(trialType)
    u_lTimes(:,j)=nanmean(up_leftTimes{j},2);
    u_rTimes(:,j)=nanmean(up_rightTimes{j},2);
    d_lTimes(:,j)=nanmean(down_leftTimes{j},2);
    d_rTimes(:,j)=nanmean(down_rightTimes{j},2);  
       
    u_lTimes_sem(:,j)=nanstd(up_leftTimes{j},[],2)./sqrt(numel(input));
    u_rTimes_sem(:,j)=nanstd(up_rightTimes{j},[],2)./sqrt(numel(input));
    d_lTimes_sem(:,j)=nanstd(down_leftTimes{j},[],2)./sqrt(numel(input));
    d_rTimes_sem(:,j)=nanstd(down_rightTimes{j},[],2)./sqrt(numel(input));
end

%% plot
fig = figure;
h=[]; legstring=[];

for j=1:numel(trialType)
    
    if j==1
        lintype = '-';
    elseif j==2
        lintype = ':';
    elseif j==3
        lintype = '--';
    else
        lintype = '-.';
    end

    legstring=[legstring {trialType{j}}];  %add to legend

    subplot(2,2,1); hold on;
    h(j,1)=plot(edges,u_lTimes(:,j),['r' lintype],'Linewidth',1);
    errorshade(edges,u_lTimes(:,j)-u_lTimes_sem(:,j),u_lTimes(:,j)+u_lTimes_sem(:,j),'r',0.2);
    ylabel({'Upsweep trials';'Lick density (Hz)'});
    title('Left lick');
        
    subplot(2,2,2); hold on;
    h(j,2)=plot(edges,u_rTimes(:,j),['b' lintype],'Linewidth',1);
    errorshade(edges,u_rTimes(:,j)-u_rTimes_sem(:,j),u_rTimes(:,j)+u_rTimes_sem(:,j),'b',0.2);
    title('Right lick');
    
    subplot(2,2,3); hold on;
    h(j,3)=plot(edges,d_lTimes(:,j),['r' lintype],'Linewidth',1);
    errorshade(edges,d_lTimes(:,j)-d_lTimes_sem(:,j),d_lTimes(:,j)+d_lTimes_sem(:,j),'r',0.2);
    ylabel({'Downsweep trials';'Lick density (Hz)'});
    xlabel('Time from sound cue (s)');
    
    subplot(2,2,4); hold on;
    h(j,4)=plot(edges,d_rTimes(:,j),['b' lintype],'Linewidth',1);
    errorshade(edges,d_rTimes(:,j)-d_rTimes_sem(:,j),d_rTimes(:,j)+d_rTimes_sem(:,j),'b',0.2);
    xlabel('Time from sound cue (s)');
    
end

% common elements for all the panels
for j=1:4
    subplot(2,2,j); hold on;
    
    % line denoting time = 0
    plot([0 0],[0 10],'Color',[0.5,0.5,0.5],'LineWidth',0.5);
    axis([edges(1) edges(end) 0 10]);   
end

% line denoting CI for time of reward (hit trials only)
CI = 95;

subplot(2,2,1);
plot([prctile(u_rewardTimes{1},(100-CI)/2) prctile(u_rewardTimes{1},100-(100-CI)/2)],[9.5 9.5],'k-','LineWidth',1);
plot([prctile(u_rewardTimes{1},(100-CI)/2) prctile(u_rewardTimes{1},(100-CI)/2)],[9.2 9.8],'k-','LineWidth',1);
plot([prctile(u_rewardTimes{1},100-(100-CI)/2) prctile(u_rewardTimes{1},100-(100-CI)/2)],[9.2 9.8],'k-','LineWidth',1);
subplot(2,2,4);
plot([prctile(d_rewardTimes{1},(100-CI)/2) prctile(d_rewardTimes{1},100-(100-CI)/2)],[9.5 9.5],'k-','LineWidth',1);
plot([prctile(d_rewardTimes{1},(100-CI)/2) prctile(d_rewardTimes{1},(100-CI)/2)],[9.2 9.8],'k-','LineWidth',1);
plot([prctile(d_rewardTimes{1},100-(100-CI)/2) prctile(d_rewardTimes{1},100-(100-CI)/2)],[9.2 9.8],'k-','LineWidth',1);

subplot(2,2,1);
legend(h(1:numel(trialType),1),legstring,'interpreter','none');

end

