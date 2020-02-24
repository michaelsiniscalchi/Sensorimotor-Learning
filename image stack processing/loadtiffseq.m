
function D = loadtiffseq(path,filename)

pathname = fullfile(path,filename);

info = imfinfo(pathname);

nX = info(1).Width;
nY = info(1).Height;
nZ = numel(info);
D=zeros(nX,nY,nZ,'uint16');  %Initialize

% Populate 3D array with imaging data from TIF file
for i=1:nZ
    D(:,:,i)=imread(pathname,i,'Info',info);
end

%---------------------------------------------------------------------------------------------------
% Comment 191212 MJ Siniscalchi:
%
%After 2019a, imread() works similarly, but read(t) takes forever... 
%
% imread() on a 9415 frame stack:
%Elapsed time is 11.148636 seconds. (2019a)
%Elapsed time is 11.230316 seconds. (2019b)
%
% tiff.read() on same stack :
%Elapsed time is 12.358082 seconds.  (2019a) - so, slightly slower than imread()...
%Elapsed time is 377.836698 seconds. (2019b) - tremendously slower (??)

%-----------------------***PREVIOUS VERSIONS***-----------------------------------------------------

% AC Kwan: code below tested 3.37sec 
%http://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/
% t = Tiff(pathname,'r');
% for i=1:nZ
%    t.setDirectory(i);
%    D(:,:,i)=t.read();
% end
% t.close();

% MJS tried this syntax, and it does not work either in MATLAB 2019b...
% if strcmp(method,'tifLib')
%     t = Tiff(pathname);
%     for i=1:nZ
%         setDirectory(t,i);
%         D(:,:,i) = read(t);
%     end
%     close(t);
% end
