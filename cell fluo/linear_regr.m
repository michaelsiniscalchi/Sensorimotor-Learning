function [ output ] = linear_regr ( signal, t, event, eventTime, trialSubset, params)
% % linear_regr %
%PURPOSE:   Multiple linear regression
%AUTHORS:   AC Kwan 170515; modified by MJ Siniscalchi 190402         
%
%INPUT ARGUMENTS
%   signal:         time-series signal (e.g., dF/F)
%   t:              time points corresponding to the signal
%   event:          event, dummy-coded (e.g., for choice, left=-1, right=1)
%                   %currently can handle up to 2 types of events, e.g., choice and outcome
%   eventTime:      the event times
%   trialSubset:    the subset of trials to investigate, all else set to NaN
%   params.window:  the time window around which to align signal
%   params.interdt: time bin duration for interpolation
%   params.regStep: duration of non-overlapping timesteps in seconds
%   params.nback:   consider events from up to this # trials back
%   params.interaction:   consider interactions?
%
%OUTPUT ARGUMENTS
%   output:         structure containing regression analysis results
%
%--------------------------------------------------------------------------

%% Interpolate signal to a finer time scale

window = params.window(1):params.regStep:params.window(end);
interdt = params.interdt;
intert = (t(1):interdt:t(end))';
intersig=interp1(t,signal,intert);

% Align signal to the event
%   use window slightly wider than the regression, so regression analysis
%   won't run into the boundaries of this variable

[sigbyTrial, tbyTrial] = align_signal(intert,intersig,eventTime,[window(1)-1 window(end)+1]);
sigbyTrial(:,~trialSubset) = NaN;

%% Construct factors and terms matrices

output.numPredictor=size(event,2);          %Number of predictors in purely additive model with no prior trial effects
output.nback = params.nback;                %Number of prior trials to consider
output.interaction = params.interaction;    %TF: consider interaction terms?

factors=[];
for j=1:output.numPredictor
    factors = [factors event(:,j)];         %Construct factors matrix from input trial masks
    for k=1:output.nback
        event_kback=[NaN(k,1); event(1:end-k,j)];     %Factor for event K trials back
        factors = [factors event_kback];
    end
end

%Construct terms matrix for one-to-three predictors from current trial and K trials back
if output.numPredictor==1
    terms=[zeros(1,1+output.nback) ; eye(1+output.nback)]; %bias, c(n), c(n-1), c(n-2), c(n-3), ...
elseif output.numPredictor==2
    if params.interaction == true
        % 'y ~ 1 + c(n)*r(n) + c(n-1)*r(n-1) + c(n-2)*r(n-2)' in Wilkinson notation.
        terms = [zeros(1,(1+output.nback)*output.numPredictor);... %Constant term
                 eye((1+output.nback)*output.numPredictor);  %Individual predictors  
                 [eye(1+output.nback) eye(1+output.nback)]]; %Interaction terms
    else
        % 'y ~ c(n) + c(n-1) + c(n-2) + r(n) + r(n-1) + r(n-2)' in Wilkinson notation.
        terms = [zeros(1,(1+output.nback)*output.numPredictor);...
                 eye((1+output.nback)*output.numPredictor)];
    end
elseif output.numPredictor ==3 
    if params.interaction == true
        terms = [zeros(1,(1+output.nback)*output.numPredictor);... 
                 eye((1+output.nback)*output.numPredictor);...
                [eye(1+output.nback) eye(1+output.nback) zeros(1+output.nback)];... 
                [eye(1+output.nback) zeros(1+output.nback) eye(1+output.nback)]];
    else
        terms=[zeros(1,(1+output.nback)*output.numPredictor) ; eye((1+output.nback)*output.numPredictor)];
    end
else
    error('This function does not handle more than 3 predictor events plus their interactions.');
end

terms = [terms zeros(size(terms,1),1)]; %Add a column of zeros for the response variable

%% parameters of the regression
step_dur = nanmean(diff(window));
step_size = step_dur;       %Non-overlapping windows
output.regr_time = (window(1)+step_dur/2:step_size:window(end)-step_dur/2)'; 
        
%% Multiple linear regression of signal for each non-overlapping time bin within trial

warning('off','MATLAB:singularMatrix');
warning('off','stats:pvaluedw:ExactUnavailable');
warning('off','stats:LinearModel:RankDefDesignMat');

for jj=1:numel(output.regr_time)
    %Indices for trial-by-trial signal within the current time step
    idx1 = sum(tbyTrial<=(output.regr_time(jj)-step_dur/2));    
    idx2 = sum(tbyTrial<(output.regr_time(jj)+step_dur/2));
    tempsig = squeeze(nanmean(sigbyTrial(idx1:idx2,:),1));

    mdl = fitlm(factors,tempsig',terms);
    for kk=1:size(terms,1)
        try
            output.coeff(jj,kk) = mdl.Coefficients.Estimate(kk);  %coefficient
            output.pval(jj,kk) = mdl.Coefficients.pValue(kk);     %pvalue for coefficient
        catch err
            output.coeff(jj,kk) = NaN;
            output.pval(jj,kk) = NaN;
            warning(err.message);
        end
    end
end

warning('on','MATLAB:singularMatrix');
warning('on','stats:pvaluedw:ExactUnavailable');
warning('on','stats:LinearModel:RankDefDesignMat');
