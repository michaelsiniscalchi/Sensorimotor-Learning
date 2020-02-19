function h = plot_ROIs(ax, cellMasks, color)        

%Plot all ROIs from a stack of cellMasks
h = gobjects(size(cellMasks,3),1);
for i = 1:numel(h)
bounds = bwboundaries(cellMasks(:,:,i)); %Boundaries of logical mask for current ROI
roi = [bounds{1}(:,2) bounds{1}(:,1)]; %Boundary coordinates in xy
h(i) = plot(roi(:,1),roi(:,2),color,'LineWidth',1);
end