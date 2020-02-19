f = gcf;
ax = findall(f.Children,'Type','axes');
leg = findall(f.Children,'Type','legend');

% Remove all titles and labels 
for i=1:numel(ax)
ax(i).Title.Visible = 'off';
ax(i).XLabel.Visible = 'off';
ax(i).YLabel.Visible = 'off';
end

% Remove figure legend
for i=1:numel(leg)
leg.Visible = 'off';
end    



% Some appearance properties to play with:
%
% ax(i).TightInset
% ax(i).LooseInset
% 
% set(gca,'layer','top');
% pu = get(gcf,'PaperUnits');
% pp = get(gcf,'PaperPosition');
% set(gcf,'Units',pu,'Position',pp)
