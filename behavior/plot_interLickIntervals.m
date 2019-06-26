function fig = plot_interLickIntervals(ILIs)

fig = figure;

fields = {'allBouts','leftBouts','rightBouts'}; 
color = {'k','r','b'};
titles = {'All bouts','Left bouts','Right bouts'}; 

for i=1:3
    ax = subplot(1,3,i);
    %[N,edges] = histcounts(ILIs.(fields{i}));
    temp = [ILIs.(fields{i}){:}];
    histogram(temp,'FaceColor',color{i});
    if i==1
        ylabel('Number of Licks');
    end
    
    %Indicate ILI-derived lick rate
    lickRate = 1/median(temp);
    txt_X = ax.XLim(1) + 6*diff(ax.XLim)/10;
    txt_Y = ax.YLim(1) + diff(ax.YLim)/10;
    txt = {'Lick rate:'; [num2str(lickRate,3) 'Hz']};
    text(txt_X,txt_Y,txt);
    
    title(titles{i});
end