function tags = get_tagStruct(pathname)

%Get image info
info = imfinfo(pathname);
info = info(1);

%Translate some of the tags into valid TIF tags
tags.ImageLength = info.Height;
tags.ImageWidth = info.Width;

%Trim off fields that are not valid tags
field_names = fieldnames(info);
field_names = field_names(ismember(field_names,Tiff.getTagNames)); 

%Assign selected fields to tif tags
for i=1:numel(field_names)
    tags.(field_names{i}) = info.(field_names{i}); 
end
tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tags.Photometric = Tiff.Photometric.MinIsBlack;
tags.Software = 'MATLAB';