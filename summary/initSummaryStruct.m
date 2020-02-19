function S = initSummaryStruct( mat_file, result_name, field_names, expData )

% Initialize summary data structure
nSessions = numel(expData);
for j=1:numel(field_names)
    S(nSessions,1).(field_names{j}) = []; %#ok<AGROW>
end

% Aggregate results
for j = 1:nSessions
    
    %Load data from struct or from file
    if ischar(result_name)
        s = load(mat_file(j),result_name);
        s = s.(result_name);
    elseif isempty(result_name)
        s = load(mat_file(j));
    end
    
    %Aggregate data in structure
    for k = 1:numel(field_names)
        if isfield(s,field_names{k})
            S(j).(field_names{k}) = s.(field_names{k});
        end
    end
    
    %Copy cell type from expData
    S(j).cellType = expData(j).cellType;
end


