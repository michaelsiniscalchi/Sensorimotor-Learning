%%% screenLogfiles
%
%Purpose: to sort logfiles, setting aside those with below threshold number of trials
%Author: MJ Siniscalchi, 180612
%
%Put all logfiles in one directory.
%
%--------------------------------------------------------------------------
clearvars;

%Set paths
smLearning_setPathList;

%Set test condition 
temp = datenum(2018,4,1);
testStr = ['bytes>50000 & datenum>' num2str(temp)]; 

%Get list of included files from raw data directory
unsorted_dir = uigetdir('C:\Users\Michael\Documents\Data & Analysis\Behavior');
flist = rdir([unsorted_dir '\**\*M*DISCRIM*.log'],testStr);

screen_dir = 'Screened logfiles';
curr_dir = cd(unsorted_dir);

try  %#ok<*TRYNC>
    rmdir(screen_dir,'s'); %Delete any prior dir for screened files 
    disp('Old directory deleted: "Screened logfiles".');
end 
mkdir(screen_dir); %Create dir for screened files

for i = 1:numel(flist)
    %Sort into subdirectories for each subject
    [pathname,filename] = fileparts(flist(i).name);
    sub_dir = fullfile(screen_dir,upper(filename(1:3)));
    if ~exist(sub_dir,'dir')
        mkdir(sub_dir); %Create sub_dir for subject
    end
        
    try    
        copyfile(flist(i).name, sub_dir)
    catch err
        warning(err.message);
        warning(flist(i).name);
    end
end

cd(curr_dir);
