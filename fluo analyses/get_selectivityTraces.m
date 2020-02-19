
function [ sel_idx, sig_bins, isSelective, prefPos, prefNeg ] = get_selectivityTraces( decode, decodeType, params )

%Extract mean selectivity and CI
M = cell2mat(decode.(decodeType).selectivity);

sel_idx = M(1:3:end,:); %Mean selectivity
CI_low = M(2:3:end,:); %Lower bound
CI_high = M(3:3:end,:); %Upper bound

% Get indices for neurons with statistically significant selectivity
post_t0 = decode.t>=0;    %Logical idx for post-trigger time bins
if strcmp(params.sig_method,'bootstrap')
    %Logical array indicating bins where zero is outside of bootstrap CI
    sig_bins = (CI_low>0 | CI_high<0);
    test_mat = sig_bins(:,post_t0); %Only include bins starting at t0
elseif strcmp(params.sig_method,'shuffle')
    sig_bins = false(size(sel_idx)); %Initialize logical array for significant time bins 
    for i = 1:size(sel_idx,1) %For each cell
        %Estimate CI for null distribution
        shuffle = 2*(decode.(decodeType).AUC_shuffle{i}-0.5); %Obtain selectivity from shuffled AUC
        CI_low = prctile(shuffle,50-params.CI/2,1);
        CI_high = prctile(shuffle,50+params.CI/2,1);
        %Compare selectivity idx to CI to find significant bins
        sig_bins(i,:) = (sel_idx(i,:)<CI_low | sel_idx(i,:)>CI_high);
    end
    test_mat = sig_bins(:,post_t0); %Only include bins starting at t0
end

nConsec = params.sig_duration/mean(diff(decode.t)); %Significance threshold: consecutive bins above chance
for j = 1:size(sel_idx,1) %For each cell
    isSelective(j,:) = testConsecTrue(test_mat(j,:),nConsec); %#ok<AGROW>
end

%Number of neurons preferring positive or negative class
pos_idx = mean(sel_idx(:,post_t0),2)>=0; %logical indices of (+) class-preferring cells
prefPos = isSelective & pos_idx; %Logical indices of (+) class-preferring cells w stat sig preference
prefNeg = isSelective & ~pos_idx;