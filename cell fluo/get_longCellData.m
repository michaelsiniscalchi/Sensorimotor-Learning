function cell_data = get_longCellData(expData,dirs,mat_files)

for i = 1:numel(expData)
    %first, collect by subject and split by phase of learning,
    %eg accuracy in prior session or some related curve fitting:
    %eg learning curve or pval(cue sound) from logistic regression.
    
    %% Load saved data
    load(fullfile(dirs.analysis,expData(i).sub_dir,mat_files.behavior),'sessionData','choice_stat');
    load(fullfile(dirs.analysis,expData(i).sub_dir,mat_files.selectivity),'bootAvg','choiceSel');
    load(fullfile(dirs.analysis,expData(i).sub_dir,mat_files.regression),'regData','modCells');
    
    %% Aggregate behavioral data
    cell_data(i).subject = sessionData.subject;
    cell_data(i).date = sessionData.dateTime(1);
    cell_data(i).criterion = expData(i).criterion;
    cell_data(i).dprime = choice_stat.dprime;
    cell_data(i).hitRate = choice_stat.correctRate;
    
    %% Multiple linear regression results
    
    % Get parameters and check for consistency
    if i==1
        fields = {'numPredictor','nback','interaction','regr_time'};
        for j=1:numel(fields)
            cell_data(i).(fields{j}) = regData(1).(fields{j});
        end
    else
        for j=1:numel(fields)
            paramCheck(j) = all(regData(1).(fields{j})==cell_data(1).(fields{j}));
        end
        if ~all(paramCheck)
            warning('Regression parameters inconsistent across experiments. Set parameters and redo!');
            clearvars reg_data
            return
        end
    end
    
    % Store regression coefficients and p-values
    for j = 1:numel(regData)
        cell_data(i).coeff(:,:,j) = regData(j).coeff;
        cell_data(i).pval(:,:,j) = regData(j).pval;
    end
    
    % Store cells modulated by Choice, Outcome, and Interaction
    cell_data(i).modCells = [modCells.Choice modCells.Outcome modCells.Interaction];
    cell_data(i).nMod = sum([modCells.Choice modCells.Outcome modCells.Interaction]);
    
    %% Results of selectivity analysis
    cell_data(i).choiceSel.t = choiceSel(1).hit.t;
    cell_data(i).choiceSel.hit = [choiceSel(:).hit.signal];
    cell_data(i).choiceSel.err = [choiceSel(:).err.signal];
    
end