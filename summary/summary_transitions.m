function transitions = summary_transitions( struct_transitions )

%% Initialize summary data structure
cellType = {'SST','VIP','PV','PYR','all'};
temp = struct('sessionID',[],'values',[],'trialIdx',[],'binValues',[],'binIdx',[],...
    'changePt1',[],'changePtsN',[],'behChangePt1',[],'behChangePt2',[],'nTrials',[]);
for i = 1:numel(cellType)
    transitions.(cellType{i}) = struct('all',temp,'sound',temp,'action',temp,...
        'sound_actionR',temp,'actionR_sound',temp,'sound_actionL',temp,'actionL_sound',temp);
end

%% Aggregate data from each session according to cell types and transition types
transTypes = fieldnames(transitions.all);
for i = 1:numel(struct_transitions) %Session index
    
    % Abbreviate and get cell type-specific session index
    T = struct_transitions(i);
    expIdx.all = i;
    expIdx.(T.cellType) = sum(strcmp({struct_transitions(1:i).cellType},T.cellType)); %Cell type spec sessionIdx
    
    % Aggregate similarity measures separately for each cell type
    cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
    for j = 1:numel(cellType)
                
        % Populate structure separately for each type of rule transition
        typeIdx = ismember(transTypes,{'sound_actionR','actionR_sound','sound_actionL','actionL_sound'});
        for k = find(typeIdx)'
            idx.(transTypes{k}) = strcmp(T.type,transTypes{k});
        end
        idx.all = true(numel(T.type),1); %all
        idx.sound = strcmp(T.type,'actionL_sound') | strcmp(T.type,'actionR_sound'); %sound
        idx.action = strcmp(T.type,'sound_actionL') | strcmp(T.type,'sound_actionR'); %action
       
        for k = 1:numel(transTypes)
            %Session identifier
            typeIdx = idx.(transTypes{k}); %Get specified transition index
            sessionID = ones(sum(typeIdx),1)*expIdx.all; %Label each transition
            
            %Trial-by-trial similarity index
            values = {T.similarity(typeIdx).values}';
            trialIdx = {T.similarity(typeIdx).trialIdx}';
            
            %Binned similarity index
            binValues = cell2mat({T.similarity(typeIdx).binValues}');
            binIdx = cell2mat({T.similarity(typeIdx).binIdx}'); %Might be able to do this just once for each type...
                     
            %Neural change-points
            changePt1 = [T.similarity(typeIdx).changePt1]'; %Using findchangepts(values(idx));
            changePtsN = {T.similarity(typeIdx).changePtsN}'; %Using find(ischange(values(idx))), so could output multiple values or empty sets.
            
            %Behavioral change-points
            behChangePt1 = T.behChangePt1(typeIdx); %MATLAB method
            behChangePt2 = T.behChangePt2(typeIdx); %Minimum cumulative deviation
            nTrials      = T.nTrials(typeIdx); %Alternative: later, subtract 19 to get transition trial
            
            %Concatenate with structure
            transitions.(cellType{j}).(transTypes{k}) = ...
                catStruct(transitions.(cellType{j}).(transTypes{k}),...
                sessionID, values, trialIdx, binValues, binIdx,...
                changePt1, changePtsN, behChangePt1, behChangePt2, nTrials);
            
        end
    end
    clearvars expIdx;
end

%% ---INTERNAL FUNCTIONS----------------------------------------------------------------------------

% Note: catStruct.m removes NaN entries. ***FUTURE: fix past work dependent on feature and remove from *.m file
%   For current purpose (with session indexing) we need to leave them in until further downstream,
%   ie summary_stats()... 

% function S = catStruct(S,varargin)
% for ii = 1:numel(varargin)
%     field_name = inputname(1+ii); %idx + 1 for struct_in
%     S.(field_name) = [S.(field_name); varargin{ii}]; %Vertical concatenation
% end