%%% calcSummaryStats()
%
% PURPOSE: To estimate commonly used parameters of an arbitrary distribution of data.
%
% AUTHOR: MJ Siniscalchi 191118
%
% INPUT ARGS:   
%               'data' (numeric), a 1D or 2D array with replicates assigned to different rows.
%               '', a vector with number of elements corresponding to
%---------------------------------------------------------------------------------------------------

function stats = calcStats( data, expID )

% Validation checks
if size(data,1) ~= length(expID) %Consistency between lengths of 'data' & 'expID'
    error('Inconsistent number of rows in "data" and "expID".');
end

% Initialize
stats = struct('data',[],'mean',[],'sem',[],'median',[],'IQR',[],'sum',[],'N',[],'expID',[]);

% Remove NaN entries
idx = all(~isnan(data),2); %Find rows containing NaN
data = data(idx,:);
expID = expID(idx,:);

% Estimate descriptive statistics
stats.data      = data;
stats.mean      = mean(data,1);
stats.sem       = std(data)/sqrt(size(data,1)); 
stats.N         = size(data,1);
stats.expID     = expID;

% Non-parametric stats for vectors only
if size(data,2)==1
    stats.median    = median(data,1);
    stats.IQR(1,:)  = prctile(data,[25,75],1); %Row vector for display in table
    stats.sum       = sum(data,1); 
end