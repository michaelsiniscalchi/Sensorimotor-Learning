%%% regress_RT()
%
% PURPOSE: To regress out linear time-varying component of reaction time for comparisons
%       across rule blocks.
%
% AUTHOR: MJ Siniscalchi, 191030
%
%---------------------------------------------------------------------------------------------------

function [ B, CI, RT_corrected, stats ] = detrend_RT( RT, blocks, P )

%Initialize
nTrials = blocks.firstTrial(end)-1;
X = [ones(nTrials,1),(1:nTrials)'];
y = RT(1:nTrials); 

%Find and remove outliers
% y(y>median(y)) = NaN; %Use only lower two quartiles for regression
y(y>prctile(y,P)) = NaN; %Use only eg lowest quartile for regression; in this case, P=25
[~,~,~,rint] = regress(y,X); %Residual is larger than P new predictions where proportion P = (1-alpha)   
outliers = rint(:,1)>0 | rint(:,2)<0;
y(outliers) = NaN;

%Regress remaining values against trial index
[B,CI,~,~,stats] = regress(y,X);

%% Obtain residuals and add intercept
X = (1:sum(blocks.nTrials))'; 
Y = B(2)*X; %Expected value: Y = b1*x + b0; 
RT_corrected = RT - Y; %Detrended reaction times