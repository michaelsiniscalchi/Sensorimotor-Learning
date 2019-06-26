function reg_data = get_longRegData(expData,dirs)

for i = 1%:numel(expData)
%first, collect by subject and split by phase of learning, 
%eg accuracy in prior session or some related curve fitting:
%eg learning curve or pval(cue sound) from logistic regression.

load(fullfile(dirs.analysis,expData(i).sub_dir,'beh.mat'),'sessionData','choice_stat');
load(fullfile(dirs.analysis,expData(i).sub_dir,'dff_and_beh.mat'),'reg_cr','modCells');

reg_data(i).subject = sessionData.subject;
reg_data(i).date = sessionData.dateTime(1);
reg_data(i).criterion = expData(i).criterion;
reg_data(i).dprime = choice_stat.dprime;
reg_data(i).hitRate = choice_stat.correctRate;

if i==1
    fields = {'numPredictor','nback','interaction','regr_time'};
    for j=1:numel(fields)
        reg_data(i).(fields{j}) = reg_cr(1).(fields{j});
    end
else
    for j=1:numel(fields)
        paramCheck(j) = reg_cr(1).(fields{j})==reg_data(1).(fields{j});
    end
    if ~all(paramCheck)
        warning('Regression parameters inconsistent across experiments. Run regression again!');
        clearvars reg_data
        return
    end
end

for j = 1:numel(reg_cr)
    reg_data(i).coeff(:,:,j) = reg_cr(j).coeff;
    reg_data(i).pval(:,:,j) = reg_cr(j).pval;
end
reg_data(i).modCells = [modCells.choice modCells.outcome modCells.interaction];

end
