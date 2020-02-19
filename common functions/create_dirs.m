%% create_dirs
%
%PURPOSE: To check for existence of multiple directories and create where necessary.
%AUTHOR: MJ Siniscalchi, 190510
%
%--------------------------------------------------------------------------

function create_dirs(varargin) 
nPaths = nargin;
for i=1:nPaths
    if ~exist(varargin{i},'dir') %varargin{i} is char vector specifying a dir name
        mkdir(varargin{i}); %create dir
    end
end