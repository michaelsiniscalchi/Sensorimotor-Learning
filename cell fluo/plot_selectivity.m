function cellOrder = plot_selectivity(input,sortParam,tlabel,xtitle,colorRange)
% % plot_selectivity %
%PURPOSE:   Plot selectivity, based on PSTHs from two conditions
%AUTHORS:   AC Kwan 170515, edited by MJ Siniscalchi 190516
%
%INPUT ARGUMENTS
%   input:       Structure containing fields {'signal',}(generated eg by calc_selectivity.m)
%   sortParam:
%       if #values = 2, e.g. [1 3], then sort the cells based on selectivity value in this time period
%       if #values = number of cells, e.g. [1 3 4 2 5], then sort the cells directly based on this ordering
%   tlabel:       Text to put as title of the plot.
%   xtitle:       Text to put as the label for x-axis.
%   colorRange:   Max and min values that define the range of the color scale
%
%OUTPUT ARGUMENTS
%   cellOrder:    Sorting order of the cells
%                 (could be fed back as input 'sortParam' for next call of
%                 this function)

%% Plotting parameters
colors=cbrewer('div','RdBu',256);
colors=flipud(colors);

%% Setup
t=input{1}.t;
nCells=numel(input);   
    
%preference is (signal_event1 - signal_event2)/(signal_event1 + signal_event2)
pref=[];
for j=1:nCells
    pref(:,j)=input{j}.signal;
end

%%
figure;

if numel(sortParam) == 2
    %sort by amplitude at specified time
%     tIdx=[max([sum(t<=sortParam(1)) 1]):sum(t<=sortParam(2))];  %index should start from at least value of 1
%     [~,cellOrder]=sort(nanmean(pref(tIdx,:),1));

    %sort the cells based on sign and timing of peak selectivity at this time point
    tIdx=[max([sum(t<=sortParam(1)) 1]):sum(t<=sortParam(2))];  %index should start from at least value of 1

    negPrefCells = find(nanmean(pref(tIdx,:),1)<0);  %determine sign of preference
    posPrefCells = find(nanmean(pref(tIdx,:),1)>=0);
    
    for j=1:numel(negPrefCells)     % sort by center of mass (mass should be all positive)
        mass = pref(tIdx,negPrefCells(j));
        mass(mass>0) = 0;
        com(j) = -sum(t(tIdx).*mass)/sum(mass);
    end
    [~,neg_idxSort]=sort(com);
    for j=1:numel(posPrefCells)
        mass = pref(tIdx,posPrefCells(j));
        mass(mass<0) = 0;
        com(j) = sum(t(tIdx).*mass)/sum(mass);
    end
    [~,pos_idxSort]=sort(com);
    cellOrder = [negPrefCells(neg_idxSort) posPrefCells(pos_idxSort)];
    
elseif numel(sortParam) == nCells
    %sort by a specified order
    cellOrder = sortParam; 
else    
    error('Error with the sortParam input for the plot_selectivity() function.');
end

%plot in pseudocolor
subplot(1,3,1);
image(t,1:nCells,pref(:,cellOrder)','CDataMapping','scaled');
hold on; plot([0 0],[0 nCells+1],'w');
colormap(colors);
caxis([colorRange(1) colorRange(2)]);      %normalize dF/F heatmap to max of all conditions
ylabel('Cells');
xlabel(xtitle);
title({tlabel;['A=' input{1}.input1_label];['B=' input{1}.input2_label]});

%make a color scale bar
subplot(3,20,60);
image(0,linspace(colorRange(1),colorRange(2),100),linspace(colorRange(1),colorRange(2),100)','CDataMapping','scaled');
colormap(colors);
caxis([colorRange(1) colorRange(2)]);
title(['(A-B)/(A+B)']);
set(gca,'YDir','normal');
set(gca,'XTick',[]);

end
