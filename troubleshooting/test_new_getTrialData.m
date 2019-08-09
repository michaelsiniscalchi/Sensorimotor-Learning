clearvars;

S1=load('C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning - MFC Lesion\analysis\M71\M71_DISCRIM_1906211536.mat');
S2=load('C:\Users\Michael\Documents\Data & Analysis\Sensorimotor Learning - MFC Lesion\analysis\M71 test\M71_DISCRIM_1906211536.mat');

fields = fieldnames(S1.trialData);
for i=[1:10,13:14]    
checkFields(i) = all(S1.trialData.(fields{i})==S2.trialData.(fields{i}));
end