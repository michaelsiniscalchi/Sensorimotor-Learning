function struct_beh = catLickDensity( struct_beh, lickDensity, cellType )

% Check if structure fields are empty
fieldname = {cellType,'all'};
for i = 1:numel(fieldname)
    if isempty(struct2cell(struct_beh.(fieldname{i}).lickDensity))
        struct_beh.(fieldname{i}).lickDensity = lickDensity;
    else
        struct_beh = mainFcn( struct_beh, lickDensity, fieldname{i} );
    end
end

function struct_beh = mainFcn( struct_beh, lickDensity, cellType )
% Lick density organized heirarchically by Choice, Cue and Rule
choice = {'left','right'};
cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};
% Vertically concatenate data with each terminal field of 'lickDensity'
for i = 1:numel(choice)
    for j = 1:numel(cue)
        for k = 1:numel(rule)
             
            struct_beh.(cellType).lickDensity.(choice{i}).(cue{j}).(rule{k}) = ...
                [struct_beh.(cellType).lickDensity.(choice{i}).(cue{j}).(rule{k});...
                lickDensity.(choice{i}).(cue{j}).(rule{k})];
            
        end
    end
end

