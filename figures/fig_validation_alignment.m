function fig = fig_validation_alignment( img_beh, params )

%Modified fig_plotAllTimeseries.m;

setup_figprops(timeseries);

% Initialize figure
figName = img_beh.sessionID;
if isempty(params.cellIDs)
    fig = figure('Name',figName);
    fig.Position = [10 100 1900 800];
else
    fig = figure('Name',[figName ' -subset']);
    fig.Position = [10 100 1900 400];
end
fig.Visible = 'off';
color = params.Color; 

% Restrict cell IDs, if specified
cellIdx = true(numel(img_beh.cellID),1);
cellID = img_beh.cellID;
if ~isempty(params.cellIDs) && ~isempty(params.expIDs)
    expIdx = strcmp(params.expIDs,img_beh.sessionID);
    cellIdx = ismember(img_beh.cellID,params.cellIDs{expIdx});
    cellID = cellID(cellIdx);
elseif ~isempty(params.cellIDs)
    cellIdx = ismember(img_beh.cellID,params.cellIDs);
    cellID = cellID(cellIdx);
end

% Extract data for plot
dFF = img_beh.dFF(cellIdx); %Restrict sample of neurons
trialDFF = img_beh.trialDFF.cueTimes(cellIdx); %Restrict sample of neurons for trial-by-trial dF/F traces
nROIs = numel(dFF); %Number of cells to plot
t = (img_beh.t ./ 60); %Unit: seconds->minutes
cueTimes = (img_beh.trialData.cueTimes ./ 60); %Unit: seconds->minutes
trigTimes = (img_beh.trialData.(params.trigTimes) ./ 60); %'cueTimes' or 'responseTimes'

% Make color-coded backdrop for each rule block
spc = params.spacing; %Unit: sd
ymax = 0;
ymin = -spc*(nROIs+0.5); %Cell idx negated so cell 1 is on top
for i = 1:numel(img_beh.blocks.type)
    firstTrial = img_beh.blocks.firstTrial(i);
    nTrials = min(img_beh.blocks.nTrials(i), img_beh.blocks.nTrials(end)-1); %First startTime of next block or last startTime of last block
    t1 = cueTimes(firstTrial); %Time of first trial in ith block
    t2 = cueTimes(firstTrial+nTrials); %Time of first trial in (i+1)th block
    switch img_beh.blocks.type{i}
        case 'sound'; c = 'w';
        case 'actionL'; c = color.red;
        case 'actionR'; c = color.blue;
    end
    fill([t1;t1;t2;t2],[ymax;ymin;ymin;ymax],c,...
        'FaceAlpha',params.FaceAlpha,'EdgeColor','none');
    hold on;
end

% Mark beginning of each trial, if desired
if params.trialMarkers
    c = cell(numel(trigTimes),1);
    c(:) = {'w'};
    c(img_beh.trials.hit) = {'k'};
    c(img_beh.trials.err) = {color.red};
    for i = 1:numel(trigTimes)
        plot([trigTimes(i),trigTimes(i)],[ymin,ymax],'-','Color',c{i},'LineWidth',0.5)
    end
end

% Plot dF/F for all cells as z-score, overlayed with aligned dF/F
for i = 1:nROIs
    % Full time series
    Y = zscore(dFF{i}) - spc*i;
    plot(t,Y,'k','LineWidth',params.LineWidth); hold on

    % Aligned segments
    % Use img_beh.trialDFF.cueTimes{i} %aligned to cue
    align_t = (img_beh.trialDFF.t ./ 60); % units sec->min
    zTrialDFF = zscore(trialDFF{i},0,'all'); %Convert to z-score for comparison to timeseries
    for j = 1:numel(trigTimes)
        X = align_t + trigTimes(j);               %idx, trial#
        Y = zTrialDFF(j,:) - spc*i;    %idx, cell#
        plot(X,Y,'r','LineWidth',params.LineWidth);
    end
end

% Label y-axis
if params.ylabel_cellIDs
    ytick = -spc*numel(cellID):spc:-spc;
    yticklabel = cellID(end:-1:1);
else
    lowTick = -10*(mod(spc*nROIs/10,10) - spc*nROIs/10); %Bottom tick spacing value
    ytick = lowTick:spc*10:-spc; %Ticks at these spacing values
    yticklabel = -lowTick/10:10:-10; %Label from 10:10:nCells from top to bottom
end
set(gca,'YTick',ytick); %Ticks at these spacing values
set(gca,'YTickLabel',yticklabel);

title(img_beh.sessionID);
ylabel('Cell Identifier'); xlabel('Time (min)');
set(gca,'box','off');
axis tight;

end
