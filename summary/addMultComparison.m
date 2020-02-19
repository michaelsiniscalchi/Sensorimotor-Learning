function mltCmpStruct = addMultComparison ( mltCmpStruct, stats, varName, comparison )

%% Fixed Parameters
dispOpts = 'off'; %'Display','off'

%% Perform Multiple Comparisons
if isstruct(stats)
    [c,~,~,gnames] = multcompare(stats,'Display',dispOpts);
    for i = 1:size(c,1)
        S(i).varName = varName;
        S(i).comparison = [gnames{c(i,1)} '-' gnames{c(i,2)}];
        S(i).diff = c(i,4);
        S(i).p = c(i,end);
    end
    
elseif strcmp(class(stats),'RepeatedMeasuresModel')   
    
    if numel(comparison)>1
        tbl = multcompare(stats,comparison(1),'By',comparison(2));
        for i = 1:size(tbl,1)
            S(i).varName = strjoin([varName,tbl{i,1}],'_');
            S(i).comparison = strjoin([tbl{i,2},tbl{i,3}],'-');
            S(i).diff = tbl.Difference(i);
            S(i).p = tbl.pValue(i);
        end
    else
        tbl = multcompare(stats,comparison);
        for i = 1:size(tbl,1)
            S(i).varName = varName;
            S(i).comparison = [tbl{i,1} '-' tbl{i,2}];
            S(i).diff = tbl.Difference(i);
            S(i).p = tbl.pValue(i);
        end
    end
    
end

%% Concatenate with Input Structure

mltCmpStruct = [mltCmpStruct S];

% Remove Empty Rows 
idx = ~cellfun(@isempty,{mltCmpStruct.comparison}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
mltCmpStruct = mltCmpStruct(idx);