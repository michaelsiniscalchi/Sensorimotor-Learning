%%% compareGroups()
%
% PURPOSE: To output basic parameters of common statistical comparisons, given grouped data.
%
% AUTHOR: MJ Siniscalchi, 200218
%
%---------------------------------------------------------------------------------------------------


function [ stats, p, stats_str ] = compareGroups( testName, data, group, wsFactors )

if nargin<4
    wsFactors = [];
end

% Fixed Parameters
displayopt = 'off'; %***For DEVO

% Perform specified statistical test
switch testName
    case 'signrank' %Across rule types or pre/post-cue 
        [p,~,stats] = signrank(data{1},data{2});
        stats.diff = median(data{2}-data{1});
        stats_str = ['W = ' num2str(stats.signedrank)]; %W statistic
    case 'ttest' %Across rule types or pre/post-cue 
        [~,p,~,stats] = ttest(data{1},data{2});
        stats.diff = mean(data{2}-data{1});
        stats_str = ['t(' num2str(stats.df) ')=' num2str(abs(stats.tstat))];
    case 'ranksum'
        [p,~,stats] = ranksum(data{1},data{2});
        stats.diff = median(data{2})-median(data{1});
        stats_str = ['W = ' num2str(stats.ranksum)]; %W statistic (if U is required, more calculation necessary...)
    case 'ttest2' 
        [~,p] = ttest2(data{1},data{2});
        stats.diff = mean(data{1})-mean(data{2});
    case 'anova1' %For across cell-types **Independence**
        %Construct grouping & data vectors
        grp = [];
        for i = 1:numel(data)
            grp = [grp; repmat(group(i),numel(data{i}),1)]; %#ok<AGROW>
        end
        data = cell2mat(data); %'data' must be column array of cells each containing a single column vector
        %Do 1-way ANOVA
        [p, tbl, stats] = anova1(data, grp, displayopt);
        df_grp = num2str(numel(stats.n)-1);
        df_err = num2str(stats.df);
        F = num2str(tbl{2,strcmp(tbl(1,:),'F')});
        stats_str = ['F(' df_grp ',' df_err ')=' F]; %Critical value
    case 'kruskalwallis' %For across cell-types **Independence**
        data = cell2mat(data);
        [p,~,stats] = kruskalwallis(data,group,displayopt);
    case {'ranova'} %For across block-types: 1-way Repeated Measures ANOVA  
        %Between Subject Factors
        N = unique(cellfun(@numel,data));
        between = table(string((1:N)')); %Between subject effect: session number
        for i = 1:size(group,1)
                response(i) = strjoin(group(i,:),'_'); %#ok<AGROW>
                between.(response(i)) = data{i}; %Response variables
        end
        modelSpec = strcat(response(1),'-',response(end),' ~ 1'); %*NOTE: completely within subject design tests intercept
        %Within Subject Factors
        within = table();
        for i = 1:size(group,2)
            within.(wsFactors{i}) = group(:,i);
        end
        withinModel = strcat(wsFactors{1},'*',wsFactors{end});
        %Fit Model and Perform Repeated Measures ANOVA
        stats = fitrm(between,modelSpec,'WithinDesign',within,'WithinModel',withinModel); %Here, 'stats' is a RepeatedMeasuresModel
        tbl = ranova(stats,'WithinModel',withinModel);
        %F-statistics
        rowNames = {...
            ['(Intercept):' wsFactors{1}];...
            ['(Intercept):' wsFactors{2}];...
            ['(Intercept):' wsFactors{1} ':' wsFactors{2}] };
        for i =1:numel(rowNames)
            idx = find(strcmp(tbl.Properties.RowNames,rowNames{i}));
            F(i) = string(num2str(tbl.F(idx),2));
            DF(i) = strjoin(string(tbl.DF(idx:idx+1)),',');
            p(i) = string(num2str(tbl.pValue(idx),2)); %p-values for factors 1, 2, & (1*2) 
        end
        p = strjoin(p,';');
        stats_str = strcat(...
            'F(',DF(1),')=',F(1),';',...
            'F(',DF(2),')=',F(2),';',... %Critical value
            'F(',DF(3),')=',F(3));
end
