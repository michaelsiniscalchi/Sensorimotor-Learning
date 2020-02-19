%%% check_consistencyImgBeh()
%
%PURPOSE: To check for consistency between behavioral and imaging data
%           before processing for analysis.
%--------------------------------------------------------------------------

function [ err_msg, err_data ] = check_consistencyImgBeh(dirs,mat_file,expData)

w = warning('off','backtrace'); %Set warning mode

err_msg = cell([numel(expData),1]);
for i = 1:numel(expData)
    
    if isfile(mat_file.stack_info(i))
        S = load(mat_file.stack_info(i));
        B = load(mat_file.behavior(i));
    else
        err_msg{i} = ['Warning: ' mat_file.stack_info(i) ' not found.'];
        warning(err_msg{i});
        continue
    end
    
    %Check whether number of trials from behavior is equal to number of raw imaging substacks
    nTrials_beh = numel(B.trialData.cue);
    nTrials_img = numel(S.rawFileName);
    if nTrials_beh ~= nTrials_img
        err_msg{i} = [expData(i).sub_dir ' has ' num2str(nTrials_beh) ' behavioral trials and '...
            num2str(nTrials_img) ' imaging substacks.'];
        warning(err_msg{i});
    end
    err_data.diff_nTrials(i) = nTrials_beh - nTrials_img;
    
    %Check whether ITIs from behavior match ITIs from imaging data
    startTimes_beh = B.trialData.startTimes - B.trialData.startTimes(1); %t0 = 0
    startTimes_img = S.trigTime - S.trigTime(1); %Time of trigger from NBS Presentation relative to first acquisition
    if nTrials_beh < nTrials_img
        %Truncate imaging data
        startTimes_img = startTimes_img(1:numel(startTimes_beh));
    elseif nTrials_beh > nTrials_img
        %Truncate behavior data
        startTimes_beh = startTimes_beh(1:numel(startTimes_img));
    end
    err_data.diff_ITIs{i} = diff([diff(startTimes_beh),diff(startTimes_img)],1,2); %Difference between ITI estimates
    err_data.sessionID{i} = expData(i).sub_dir;
end

err_msg = err_msg(~cellfun(@isempty,err_msg)); %Remove all empty entries
warning(w); %Reset warning mode