function npPolys = plot_npMasks(ax, npMasks, color)        

% Plot all ROIs from a stack of cellMasks

npPoly = gobjects(size(npMasks,3),1); %Inititialize graphics array
for i = 1:numel(npPoly)
    npPoly = polyshape(size(npMasks,3),1); %Polygon vertices for the neuropil 'subtractmask' for each ROI polyshape
    bounds = bwboundaries(cellMasks(:,:,i)); %Boundaries of logical mask for current ROI
    roi = [bounds{1}(:,2) bounds{1}(:,1)]; %Boundary coordinates in xy
    h(i) = plot(roi(:,1),roi(:,2),color,'LineWidth',1);
end


npPoly(i) = getNpPoly(S.subtractmask); %Generate polygon representation (graphics object)