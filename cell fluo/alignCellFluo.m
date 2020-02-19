%% align2Event()
%
% PURPOSE: To align cellular fluorescence to a specified behavioral/physiological 
%               event repeated within an imaging session.
%
% AUTHOR: MJ Siniscalchi, 190910
%
% INPUT ARGS:   
%           struct 'cells', containing fields 'dFF' and 't'.
%
% OUTPUTS:  
%           struct 'aligned, containing fields:
%                   -'(params.trigTimes).dFF', a cell array (nCells x 1) containing aligned 
%                       cellular fluorescence as a matrix (nTriggers x nTimepoints).
%                   -'t', a vector representing time relative to the specified event.
%
%--------------------------------------------------------------------------

function aligned = alignCellFluo(cells,trialData,params)

% Assign to output any existing aligned signals
if isfield(cells,'aligned')
    aligned = cells.aligned;
end

% Interpolate dF/F for more fine-grained alignment
dt = params.interdt;
t = cells.t(1) : dt : cells.t(end); %Interpolated time
dFF = interp1(cells.t,cell2mat(cells.dFF'),t); %Interpolated time x cell number

% Get nearest time index for each event time
rel_idx = round(params.window(1)/dt) : round(params.window(end)/dt); %In number of samples
event_times = trialData.(params.trigTimes);
idx = NaN(numel(event_times),numel(rel_idx));
for i = 1:numel(event_times)
    idx_t0 = find(t >= event_times(i)-dt/1.999 & t <= event_times(i)+dt/1.999,1,'first'); %Occasional small errors in interp1() output, with exactly centered event_times(i) yield null set or two results with threshold set to dt/2
    idx(i,:) = idx_t0 + rel_idx;
end
% Handle idxs for out-of-range timepoints
nanIdx = idx < 1 | idx > numel(t); %Idx for out-of-range timepoints
idx(idx < 1) = 1; 
idx(idx > numel(t)) = numel(t);

% Align interpolated signals
aligned.(params.trigTimes) = cell([numel(cells.dFF),1]); %Initialize
for i = 1:numel(cells.dFF)
    cell_dFF = dFF(:,i);
    aligned.(params.trigTimes){i} = cell_dFF(idx);  %Populate matrix of dimensions nTriggers x nTimepoints
    aligned.(params.trigTimes){i}(nanIdx) = NaN; %Exclude out-of-range timepoints
end
aligned.t = rel_idx * dt; %Time relative to specified event