function roiData = getMasterROIs( roi_dirs, master_filename )

nROIs = 0; %Initialize counter
for i = 1:numel(roi_dirs)
    file_list = dir(fullfile(roi_dirs{i},'*cell*.mat'));
    
    for j = 1:numel(file_list)
        S = load(fullfile(roi_dirs{i},file_list(j).name));
        fields = fieldnames(S);
        for k = 1:numel(fields)
            roiData.(fields{k}){nROIs+1} = S.(fields{k});
        end
        [startIdx,endIdx] = regexp(file_list(j).name,'cell\d{3}');
        roiData.cell_ID{nROIs+1} = file_list(j).name(startIdx+4:endIdx);
        
        [~,name,ext] = fileparts(roi_dirs{i});
        temp = strjoin({name,ext},'');
        roiData.fname_stack{nROIs+1} = temp(5:end); %Remove prefix: 'ROI_'
        nROIs = nROIs+1;
    end
end

save(master_filename,'-STRUCT','roiData');