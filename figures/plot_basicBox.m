function h = plot_basicBox( X, data, boxWidth, lineWidth, color )

l = X-0.5*boxWidth;       %Box left
r = X+0.5*boxWidth;       %Box right
t = prctile(data,75);     %Box top: Q3
b = prctile(data,25);     %Box bottom: Q1

med = median(data);       %Median (Q2)
wl = prctile(data,9);     %Whisker low  (9th; see theory on 7-number summary...)
wh = prctile(data,91);    %Whisker high (91th; see theory on 7-number summary...)

p = patch([l l r r],[b t t b],color,'EdgeColor',color,'LineWidth',lineWidth); hold on;
ln(1) = plot([X X]',[wl b]','-','Color',color); %Low Whisker
ln(2) = plot([X X]',[t wh]','-','Color',color); %High Whisker
ln(3) = plot([l r]',[med med]','-','Color',color); %High Whisker

p.FaceAlpha = 0.5;
set(ln(:),'LineWidth',lineWidth);