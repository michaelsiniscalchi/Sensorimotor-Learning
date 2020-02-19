
function S = catStruct(S,varargin)
for ii = 1:numel(varargin)
    field_name = inputname(1+ii); %idx + 1 for struct_in
%     if ~iscell(varargin{ii}) && all(isnan(varargin{ii}),'all') %Note: 'cellID' is cell
%         varargin{ii} = []; %Remove NaN entries (eg all(~isSelective)) 
%     end
    S.(field_name) = [S.(field_name); varargin{ii}]; %Vertical concatenation
end

%***Note: these lines should be removed, once downstream analyses are modified to remove NaNs:
% if ~iscell(varargin{ii}) && all(isnan(varargin{ii}),'all') %Note: 'cellID' is cell
%     varargin{ii} = []; %Remove NaN entries (eg all(~isSelective))
% end