function summary = summary_selectivity( summary, decode, cell_type, expID, cellID, params )


%---------------------------------------------------------------------------------------------------

%Initialize output structure
decodeType = fieldnames(decode);
decodeType = decodeType(~strcmp(decodeType,'t'));
for i=1:numel(decodeType)
    if ~isfield(summary.(decodeType{i}),cell_type)
        summary.(decodeType{i}).(cell_type) =...
            struct('selIdx_cells_t',[],'isSelective',logical([]),'prefPos',[],'prefNeg',[],...
            'expID',[],'cellID',[],...
            'selIdx_t',[],'selMag_t',[],'sigIdx_t',[],'sigMag_t',[],'pSig_t',[],...
            'selIdx',[],'selMag',[],'sigIdx',[],'sigMag',[],'pSig',[],...
            'pPrefPos',[],'pPrefNeg',[],'nCells',[]);
    end
end

% Get all selectivity classes generated in ROC analysis 
for i = 1:numel(decodeType)
    
    %% AGGREGATE AND REDUCE SELECTIVITY RESULTS
    
    %Extract selectivity idxs, idx for stat. sig., and number of neurons prefering +/- classes 
    [ selIdx_cells_t, isSig_cells_t, isSelective, prefPos, prefNeg ] =...
        get_selectivityTraces(decode,decodeType{i},params);
    
    %Estimate mean selectivity, magnitude, and P significantly selective as f(t) 
    selIdx_t    = mean(selIdx_cells_t,1); %Mean selectivity idx as a function of time
    selMag_t    = mean(abs(selIdx_cells_t),1); %Mean selectivity magnitude as a function of time
    sigIdx_t    = mean(selIdx_cells_t(isSelective,:),1); %Mean selectivity idx as a function of time 
    sigMag_t    = mean(abs(selIdx_cells_t(isSelective,:)),1); %Mean selectivity magnitude for sig. selective neurons
    pSig_t      = mean(isSig_cells_t,1); %Proportion of neurons significantly selective as function of time   
    
    %Collapsed over time post-trigger
    timeIdx = decode.t>0;
    selIdx  = mean(selIdx_t(timeIdx));
    selMag  = mean(selMag_t(timeIdx));
    sigIdx  = mean(sigIdx_t(timeIdx));
    sigMag  = mean(sigMag_t(timeIdx));
    pSig    = mean(isSelective);
        
    %Additional variables
    pPrefPos = mean(prefPos);
    pPrefNeg = mean(prefNeg);
    expID  = expID.*ones(size(selIdx_cells_t,1),1); %Corresponds to expData(expID)
    nCells = size(selIdx_cells_t,1); %Number of cells in FOV

    %% INCORPORATE INTO SUMMARY DATA STRUCTURE
    
    summary.(decodeType{i}).(cell_type) = catStruct(summary.(decodeType{i}).(cell_type),...
         selIdx_cells_t, isSelective, prefPos, prefNeg, expID, cellID,... %Vars aggregated across all neurons
         selIdx_t, selMag_t, sigIdx_t, sigMag_t, pSig_t,... %Vars averaged by experiment
         selIdx, selMag, sigIdx, sigMag, pSig,...
         pPrefPos, pPrefNeg, nCells); %struct_out = catStruct(struct_in,varargin)
          
end

% function S = catStruct(S,varargin)
% for ii = 1:numel(varargin)
%     field_name = inputname(1+ii); %idx + 1 for struct_in
%     if ~iscell(varargin{ii}) && all(isnan(varargin{ii}),'all') %Note: 'cellID' is cell
%         varargin{ii} = []; %Remove NaN entries (all(~isSelective)) 
%     end
%     S.(field_name) = [S.(field_name); varargin{ii}];
% end
