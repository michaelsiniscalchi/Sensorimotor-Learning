function fig = image_priorROIs( cell_ID, width, handles )
%handles.masterROIs_filename =...
 %   'C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning\data\master_rois_M52.mat';

load(handles.masterROIs_filename,'frameSegment','bw'); %could use matfile() if this takes too long...
idx = find(strcmp({frameSegment.cell_ID}, cell_ID),1,'first'); %cell_ID = '001'
frameSegment = frameSegment(idx);
[nY,~] = size(bw{1});

%% Create figure for each series of frame segments
%Figure position
Y = frameSegment.centroid{1}(2);
if Y < 0.5*nY
    fig_pos = [100,100,width,width];
else fig_pos = [100,800,width,width];
end

%Image ROI and surrounding pixels for each session
i = 1; %Initialize image index
end_idx = numel(frameSegment.pix);

fig = figure('Visible','on','NumberTitle','off','WindowButtonDownFcn',@mouseClick);
fig.Position = fig_pos;
fig.MenuBar = 'none';
fig.ToolBar = 'none';

plotROI(frameSegment);

    function mouseClick(src,event)
        disp('clicked');
        disp([i end_idx]);
        if i<end_idx
            i=i+1;
        else
            i=1;
        end
        plotROI(frameSegment)
    end

    function plotROI(frameSegment)
        imagesc(frameSegment.pix{i}); hold on
        plot(frameSegment.roi{i}(:,1),frameSegment.roi{i}(:,2),'r');
        ax = gca;
        ax.Position = [0,0,1,1];
        ax.YTickLabel = []; ax.XTickLabel = [];
        axis square;
    end

end