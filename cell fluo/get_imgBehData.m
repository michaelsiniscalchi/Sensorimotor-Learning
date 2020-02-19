%%% getImgBehData()
%
%PURPOSE: To reconcile behavioral data acquired in NBS Presentation with
%           calcium imaging data simultaneously acquired in ScanImage.
%
%AUTHOR: MJ Siniscalchi, 190904

function results = get_imgBehData( beh_data, stack_info )

%Check if number of trials from behavior is equal to number of raw imaging substacks
    if numel(B.trialData.cue) < numel(S.rawFileName)
        err_msg{i} = ['Warning: ' expData(i).sub_dir ' has fewer behavioral trials than imaging substacks.'];
        warning(err_msg{i});
        %Truncate imaging data to match behavioral data
        %expData(i).mat_path = expData(i).mat_path(1:numel(B.trialData.cue));
        %Then run calc_cellF, etc...
    elseif numel(B.trialData.cue) > numel(S.rawFileName)
        err_msg{i} = ['Warning: ' expData(i).sub_dir ' has more behavioral trials than imaging substacks.'];
        warning(err_msg{i});
        %Truncate behavioral data  to match imaging data
        %fields = fieldnames(B.trials)
        %for j = 1:numel(fields)
        %end
        %fields = fieldnames(B.trialData)
        %for j = 1:numel(fields)
        %end
    end