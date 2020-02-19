%%% plot_cdfChoiceSel
%
%PURPOSE: To plot changes in the distribution of choice selectivity magnititudes
%           estimated from longitudinal calcium imaging during the learning 
%           of an auditory-motor task
%
%AUTHOR: MJ Siniscalchi, 190401
%
%NOTES:
%Analyses for all cells
% Compare distribution of choice selectivity magnitudes for all cells*animals across training stages. 
% ECDF for all; median across cells per animal; take mean +- sd across animals.

%Track cells across time?
% Is choice preference/selectivity maintained across time?
% For each cell, quantify change in choice selectivity over learning

function fig = plot_cdfChoiceSel( cellData )

nSessions = numel(cellData);
t = cellData(1).choiceSel.t;
timeIdx = find(t>0 & t<5); %Time from alignment event

fields = {'hit' 'err'};
for i = 1:2
    for j=1:numel(cellData)
        % Selectivity magnitude for each cell averaged over 0<t<5 s
        selIdx.(fields{i})(:,j) = nanmean(abs(cellData(j).choiceSel.(fields{i})(timeIdx,:))); %cells x session num
        
        % Empirical cumulative distribution of selectivity magnitude
        [CDF.(fields{i})(:,j),X.(fields{i})(:,j)] = ecdf(selIdx.(fields{i})(:,j));
        
        % Median choice selectivity
        med_sel.(fields{i})(j) = median(selIdx.(fields{i})(:,j));
    end
    
    % Selectivity for each cell, first and last session
    sel_init.(fields{i}) = nanmean(cellData(1).choiceSel.(fields{i})(timeIdx,:))';
    sel_final.(fields{i}) = nanmean(cellData(end).choiceSel.(fields{i})(timeIdx,:))';
end

factors = {'choice','outcome','interaction'};
for i = 1:numel(factors)
    for j = 1:numel(cellData)
        nMod.(factors{i})(j) = sum(cellData(j).modCells(:,i));
    end
end

%% Plots

% Setup color order and initialize axes
C = [0:1/(nSessions-1):1; zeros(1,nSessions); 1:-1/(nSessions-1):0]'; %Color order: B->R

fig = figure;
for i=1:2
ax(i) = axes('ColorOrder',C,'NextPlot','replacechildren'); %Setup color order for axes
end

% Panel 1
subplot(4,4,[1:2 5:6],ax(1))
for i=1:nSessions
plot(ax(1),X.hit(:,i),CDF.hit(:,i)); hold on
end
title('Correct trials');

% Panel 2
subplot(4,4,[3:4 7:8],ax(2))
for i=1:nSessions
plot(ax(2),X.err(:,i),CDF.err(:,i)); hold on
end
title('Error trials');

ax(1).YLabel.String = 'Cumulative proportion';
for i=1:2
ax(i).XLabel.String = 'Choice selectivity magnitude';
ax(i).XLim = [0 0.5];
end

% Panels 3 & 4: median choice selectivity magnitude
pos = {13,15};
for i = 1:2
subplot(4,4,pos{i});
ax(i+2) = gca;
bar(1:nSessions,med_sel.(fields{i}));
ax(i+2).XLabel.String = 'Session number';
ax(i+2).Box = 'off';
end
ax(3).YLabel.String = 'Median magnitude';

% Panels 5 & 6: choice selectivity of each cell for first vs. last session
pos = {14,16};
for i = 1:2
subplot(4,4,pos{i});  hold on;
ax(i+4) = gca;
plot([-1 1],[-1 1],'k-','LineWidth',1);
scatter(sel_init.(fields{i}),sel_final.(fields{i}),2);
ax(i+4).XLim = [-0.3 0.3]; ax(i+4).YLim = [-0.3 0.3];
ax(i+4).XLabel.String = 'After hitrate = 50%';
ax(i+4).Box = 'off';
end
ax(5).YLabel.String = 'After hitrate = 90%';