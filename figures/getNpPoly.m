function poly = getNpPoly(mask)
B = bwboundaries(mask);
warning('off','MATLAB:polyshape:repairedBySimplify');
if size(B,1)==1 %Eg if annulus is interrupted and has no holes
    poly = polyshape(B{1}(:,2),B{1}(:,1)); %X-,Y-coordinates
else
    nPoints = cellfun(@(C) size(C,1),B)'; %Number of points in each polygon
    start_idx = cumsum([0 nPoints+1])+1; %Starting idx for each series of points (series separated by NaN)
    X = NaN(sum(nPoints)+numel(nPoints)-1,1); %Initialize vector with space for NaN between each series of points
    Y = X;
    for i=1:numel(nPoints)
        X(start_idx(i):start_idx(i)+nPoints(i)-1) = B{i}(:,2);
        Y(start_idx(i):start_idx(i)+nPoints(i)-1) = B{i}(:,1);
    end
    poly = polyshape(X,Y);
end