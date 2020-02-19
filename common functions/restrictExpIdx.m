function expIdx = restrictExpIdx( expIDs, specIDs )  

%Restrict to specific sessions, if desired
expIdx = 1:numel(expIDs);
if ~isempty(specIDs)
    expIdx = find(ismember(expIDs, specIDs));
end

