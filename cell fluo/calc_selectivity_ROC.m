function [ selectivity, accuracy ] = calc_selectivity_ROC(cells, trigTimes, trialType1, trialType2, subset_label, params)

disp('Calculating selectivity index using AUROC...');

window = params.window;
interpTime = (cells.t(1):params.interdt:cells.t(end))';

nT = 1 + (window(end)-window(1))/params.interdt; %Number of timepoints in tByTrial 
selectivity = struct('idx',nan(nT,1),'CI',nan(nT,2));

decodeAcc = nan(nT,1);
for i = 1:numel(cells.dFF)
    disp(['Cell ' num2str(i) '\' num2str(numel(cells.dFF)) '...']);
    
    signal = cells.dFF{i};
    interpSignal = interp1(cells.t,signal,interpTime);
    [dffByTrial, tByTrial] = align_signal(interpTime,interpSignal,trigTimes,window);
    
    %For each time point in trial
    AUC = nan(nT,3); %Pre-allocate memory
    for j = 1:numel(tByTrial)
        dFF = dffByTrial(j,:)'; %dFF from specified timepoint in each trial (col vector).
        [AUC(j,:),decodeAcc(j)] = calc_ROC(dFF,trialType1,trialType2);
    end
    selIdx = 2*(AUC-0.5);
        
    %Store in structure compatible with plotting functions
    selectivity(i).t = tByTrial;
    selectivity(i).signal = selIdx(:,1);
    selectivity(i).CI = selIdx(:,2:3);
    selectivity(i).subset_label = subset_label;
    selectivity(i).nEvent = [sum(trialType1),sum(trialType2)];
    
    accuracy(i).t = tByTrial;
    accuracy(i).signal = decodeAcc;
    accuracy(i).subset_label = subset_label;
    accuracy(i).nEvent = [sum(trialType1),sum(trialType2)];
    accuracy(i).meanByTrial = nanmean(decodeAcc(tByTrial>=0));
    
end