function errorshade( X, CI_low, CI_high, color, transparency )
% % errorshade(x,h,l,c) %
%PURPOSE:   Plot shaded area, e.g. for confidence intervals
%AUTHORS:   AC Kwan 170515
%           -edited 190912 MJ Siniscalchi: same var used for upper bound
%                   data as for fill object handle (fixed).
%
%INPUT ARGUMENTS
%   X: Independent variable
%   CI_high: Upper bound for the dependent variable
%   CI_low: Lower bound for the dependent variable
%   color: Color of shading, e.g., [0.5 0.5 0.5] for medium gray
%   transparency:  AlphaTransparency value (0 to 1; 1 ~ opaque)

%%
if nargin < 5
    transparency = 0.5; %No faceAlpha specified
end

X = X(:)';
CI_low = CI_low(:)';
CI_high = CI_high(:)';

% Fill the shaded area
f = fill([X fliplr(X)],[CI_low fliplr(CI_high)],color,'LineStyle','none');
set(f,'FaceAlpha',transparency);