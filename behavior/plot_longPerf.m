function figs = plot_longPerf( stats )

subject = fieldnames(stats);
X = @(subject_idx) datenum(stats.(subject{subject_idx}).date')...
    -datenum(stats.(subject{subject_idx}).date{1})+1; %Number of training sessions

figs(1) = figure('Name','Hit Rate Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).hitRate,'k','LineWidth',3);
plot(X(i),stats.(subject{i}).hitRateL,'r:','LineWidth',1);
plot(X(i),stats.(subject{i}).hitRateR,'b:','LineWidth',1);
xlabel('Training days');
ylabel('Correct rate (%)');
ylim([0 1]);
end

figs(2) = figure('Name','Discrimination Index Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).dprime,'LineWidth',3);
xlabel('Training days');
ylabel('Discrimination index (d")');
ylim([-0.5 5]);
end

figs(3) = figure('Name','Bias Index Across Training Sessions');
for i=1:numel(subject)
p = subplot(2,5,i); hold on;

Y = stats.(subject{i}).hitRateR - stats.(subject{i}).hitRateL;
plot(X(i),Y,'LineWidth',3);
plot(p.XLim,[0 0],':k');

title(subject{i});
xlabel('Training days');
ylabel('Correct rate: (%R - %L)');
ylim([-1 1]);
end

figs(4) = figure('Name','Number of Licks Pre-Cue and Pre-Reward Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).avgLicksPreCue,'m-','LineWidth',3);
plot(X(i),stats.(subject{i}).avgLicksPreRew,'c-','LineWidth',3);
xlabel('Training days');
ylabel('Number of licks in 500ms time window');
ylim([0 10]);
end

figs(5) = figure('Name','Anticipatory Licking Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).pPreCueTrials,'LineWidth',3);
xlabel('Training days');
ylabel('Proportion of trials with pre-cue licking');
ylim([0 1]);
end

figs(6) = figure('Name','Median Reaction Time Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).medianRT,'k','LineWidth',3);
plot(X(i),stats.(subject{i}).medianRT_hit,'Color',[0.5 0.5 0.5],'LineWidth',1);
plot(X(i),stats.(subject{i}).medianRT_err,':','Color',[0.5 0.5 0.5],'LineWidth',1);
xlabel('Training days');
ylabel('Median reaction time (s)');
ylim([0 0.5]);
end

figs(7) = figure('Name','Proportion of Correct Reactions Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).pCorrectReaction,'k','LineWidth',3);
plot(X(i),stats.(subject{i}).pCorrectReactionHit,'Color',[0.5 0.5 0.5],'LineWidth',1);
plot(X(i),stats.(subject{i}).pCorrectReactionErr,':','Color',[0.5 0.5 0.5],'LineWidth',1);
xlabel('Training days');
ylabel('Proportion of trials');
ylim([0 1]);
end

figs(8) = figure('Name','Congruence of Reaction and Response Across Training Sessions');
for i=1:numel(subject)
subplot(2,5,i); hold on;
title(subject{i});
plot(X(i),stats.(subject{i}).pSameReactResp,'LineWidth',3);
xlabel('Training days');
ylabel('Proportion of trials where reaction = response');
ylim([0 1]);
end

% Y2 = smoothdata(Y,'movmedian',5);
% plot(X,Y2,'LineWidth',3);
% plot(X,Y,'.','LineStyle','none');