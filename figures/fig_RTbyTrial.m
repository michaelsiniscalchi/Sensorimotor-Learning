function fig = fig_RTbyTrial( behavior, params, corr_flag)


B = behavior; %Unpack
RT = B.trialData.reactionTimes * 1000; %Reaction time in ms
nTrials = numel(RT);

sessionID = [B.sessionData.subject ' ' datestr(B.sessionData.dateTime{1},'yymmdd')];
if nargin<3 || ~strcmp(corr_flag,'correct')
    corr_flag = false;
    fig = figure('Name',['Reaction_time_by_trial' sessionID]);
else
    fig = figure('Name',['Reaction_time_by_trial ' sessionID 'corrected']);
end

fig.Visible = 'off';
fig.Position = [100 100 1200 800];

% Regress RT against trial idx
[b,CI,RT_corrected,stats] = detrend_RT( RT, B.blocks );
if corr_flag
    RT = RT_corrected;
end

%Make color-coded backdrop for each rule block
c(1:numel(B.blocks.type),:) = {'w'};
c(strcmp(B.blocks.type,'actionL')) = {'r'};
c(strcmp(B.blocks.type,'actionR')) = {'b'};
ylims = [min(RT) - 0.1*range(RT), max(RT) + 0.1*range(RT)];

for i = 1:numel(B.blocks.type)
    t1 = B.blocks.firstTrial(i) - 0.5; %Overlap first trial in ith block
    t2 = B.blocks.firstTrial(i) + B.blocks.nTrials(i) - 0.5; %Overlap last trial in i-th block
    fill([t1;t1;t2;t2],[ylims(2);ylims(1);ylims(1);ylims(2)],c{i},'FaceAlpha',params.FaceAlpha,'EdgeColor','none'); hold on;
end

% Plot reaction times
c(1:nTrials,:) = {'w'};
c(B.trials.hit) = {'k'};
c(B.trials.err) = {'r'};
for i = 1:nTrials
    plot(i,RT(i),'.','Color',c{i});
end

% Plot regression line
X = 1:B.blocks.firstTrial(end)-1;
if corr_flag
    Y = b(1)*ones(size(X));
    plot(Y,':','Color','k','Marker','none','LineWidth',1);
else
    Y = b(2).*X + b(1);
    plot(Y,'-','Color','b','Marker','none','LineWidth',2);
    for i = 1:2 %CI bounds
        Y2 = CI(2,i)*X + CI(1,i);
        plot(Y2,':','Color','b','Marker','none','LineWidth',1);
    end
end

text(nTrials-200,10,['R^2 = ' num2str(stats(1))],'FontSize',12);

%Label x- and y-axis
ylabel('Reaction time (ms)');
xlabel('Trial index');
title([sessionID ': Reaction Times']);
set(gca,'box','off');
axis tight;