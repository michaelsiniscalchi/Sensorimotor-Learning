function D = loadtiffseq(pathname,filename)

file_loc = fullfile(pathname,filename);

info=imfinfo(file_loc);

nX = info(1).Width;
nY = info(1).Height;
nZ = numel(info);
D=zeros(nX,nY,nZ,'uint16');  %pre-generate an empty array

%code below tested 3.37sec
%http://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/
%TifLink = Tiff(strcat(pathname,filename), 'r');
TifLink = Tiff(file_loc,'r');
for i=1:nZ
   TifLink.setDirectory(i);
   D(:,:,i)=TifLink.read();
end
TifLink.close();

% %code below tested 5.02sec
% for i=1:nZ
%     D(:,:,i)=imread(strcat(pathname,filename),i,'Info',info);
% end