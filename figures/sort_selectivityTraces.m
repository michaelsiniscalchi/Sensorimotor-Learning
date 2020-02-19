function [ sel_sorted, sig_sorted, cell_idx, pref_idx ] = sort_selectivityTraces( sel_idx, isSelective, time )

%Sort by center of mass starting at t0
post_t0 = time>=0;    %Idx: post-trigger time bins
val = sel_idx(:,post_t0); %Values: post-trigger time bins
[col,~] = meshgrid(1:size(val,2),1:size(val,1)); %Column idx (x1,x2...xn)
c_mass = sum(col.*val,2) ./ sum(val,2); % (m1*x1+m2*x2...mn*xn)/(m1+m2+...mn)
[~,cell_idx] = sort(c_mass); %linear indices of sorted cells

%Sort traces by mean preference for positive or negative class
pref_idx = mean(sel_idx(cell_idx,post_t0),2)>=0; %logical indices of (+) class-preferring cells
cell_idx = [cell_idx(pref_idx); cell_idx(~pref_idx)]; %Sorted idxs for all outputs: first by pref, then by c_mass

%Sorted traces and idxs
sel_sorted = sel_idx(cell_idx,:);
sig_sorted = isSelective(cell_idx);
pref_idx = sort(pref_idx,'descend'); 