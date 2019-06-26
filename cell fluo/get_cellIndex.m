%% get_cellIndex
%
%PURPOSE: Get the data indices in 'cells' corresponding to cell IDs specified in the input arg 'cellIDs'
%AUTHOR: MJ Siniscalchi 190516

function cellIdx = get_cellIndex(cells,cell_IDs)

cellIdx = zeros(size(cell_IDs)); %Initialize

%Indices for cells to be plotted
if isfield(cells,'cellID') && ~isempty(cell_IDs)
    %Inclusion idx defined and 'cells' struct includes field for cell ID
    ID_list = cellfun(@str2num,cells.cellID); 
    for i = 1:numel(cell_IDs)
        tempIdx = find(ID_list==cell_IDs(i)); %Idx of cell with corresponding cell ID 
        if ~isempty(tempIdx), cellIdx(i) = tempIdx;
        else, error('Cell ID specified in "params" was not found in "cells" structure.');
        end
    end
elseif ~isempty(cell_IDs)
    %Inclusion idx defined, but no cell IDs in 'cells' struct
    cellIdx = cell_IDs; %Idx in this case is just the idx from 'cells' struct.
else
    %Inclusion idx set to '[]' or undefined
    cellIdx = 1:numel(cells.dFF); %If no inclusion idx given, include all.
end