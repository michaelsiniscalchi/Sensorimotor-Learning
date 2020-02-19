function figData = getFigData( dirs, expData, expIdx, mat_file, figID, params )

switch figID
    
    case 'FOV_mean_projections'
       
        % Initialize file
        if ~exist(mat_file.figData.fovProj,'file')
            figData.meanProj{numel(expData)}    = []; %One cell for each session
            figData.roi_dir{numel(expData)}     = [];
            save(mat_file.figData.fovProj,'-struct','figData');
        else
            figData = load(mat_file.figData.fovProj);
        end
        
        % Calculate or re-calculate mean projection from substacks
        if params.figs.fovProj.calcProj
            for i = 1:numel(expIdx)
                % Get path to required data
                exp = expData(expIdx(i));                
                figData.meanProj{expIdx(i)} = calc_meanProj(exp.mat_path);
                figData.roi_dir{expIdx(i)} = fullfile(dirs.data, exp.sub_dir, exp.roi_dir);
            end
            save(mat_file.figData.fovProj,'-struct','figData','-append'); %Save mean projection, etc. for later use
        end    
end