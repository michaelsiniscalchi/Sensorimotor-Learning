function [ data, group ] = getStatsData( stats_struct, field_spec)

%% Extract Data for Descriptive Stats or Comparisons

% Follow structure to specified terminal fields
fields = []; 
group = [];
for i = 1:numel(field_spec)
    nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
    if length(field_spec{i})==1                               %Individual fieldnames specified as char
        copyField = repmat(field_spec{i},nCopies,1);   %Copy new fieldname for each existing higher-order field
        fields = [fields,copyField];
    else 
        copyField = repmat(field_spec{i},1,nCopies);   %Duplicate new fields for each existing row, eg, ['a','a','a';'b','b','b']
        copyField = reshape(copyField',numel(copyField),1); %Transpose and reshape to column vector, eg, ['a';'a';'a';'b';'b';'b']
        fields = repmat(fields,numel(field_spec{i}),1);     %Copy higher-order fields for each subordinate field specified
        fields = [fields, copyField];                       %Append new set of fieldnames       
    end
end

% Construct grouping array from factor names
factorIdx = cellfun(@length,field_spec)>1;
group = fields(:,factorIdx);

% Extract specified data from 'stats'
for i = 1:size(fields,1)
    %Reduce struct to specified terminal field if present
    s = stats_struct;
    for j = 1:size(fields,2)
        if isfield(s,fields(i,j))
            s = s.(fields(i,j));
        end
    end
    %Aggregate data from each terminal field 
    if isfield(s,'data')
        data{i,1} = s.data; %Must be column vector
    end
end