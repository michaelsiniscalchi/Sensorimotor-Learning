function stackInfo = get_stackInfo(raw_path)

disp('Fetching stackInfo: metadata from image files...');

%Header info from scim_openTif()
header = scim_openTif(raw_path{1});
stackInfo.imageWidth    = header.acq.pixelsPerLine;
stackInfo.imageHeight   = header.acq.linesPerFrame;
stackInfo.frameRate     = header.acq.frameRate;
stackInfo.zoomFactor    = header.acq.zoomFactor;
stackInfo.nChans        = header.acq.numberOfChannelsSave;

for i = 1:numel(raw_path)
    
    %Waitbar
    f = waitbar(0);
    msg = ['Processing stack ' num2str(i) '/' num2str(numel(raw_path)) '...'];
    waitbar(i/numel(raw_path),f,msg);
    
    %Filename from raw substacks
    [~,fname,ext] = fileparts(raw_path{i});
    stackInfo.rawFileName{i} = [fname ext];
        
    %Number of frames per substack
    stackInfo.nFrames(i)    = length(imfinfo(raw_path{i}))/stackInfo.nChans;
    
    %Get trigger timestamp and delay from scim_openTif()
    header = scim_openTif(raw_path{i}); %Get header info
    trigTime = datetime(header.internal.triggerTimeString,'InputFormat','M/d/yyyy H:m:s.SSS'); %As datetime for easier calculations
    firstTrigTime = datetime(header.internal.triggerTimeFirstString,'InputFormat','M/d/yyyy H:m:s.SSS');
    
    %Store trigger time as difference in seconds between current trigger and first trigger timestamps
    stackInfo.trigTime(i) = seconds(trigTime - firstTrigTime); %Time from first trigger in seconds
    stackInfo.trigDelay(i) = header.internal.triggerFrameDelayMS/1000; %Delay in seconds between trigger and time of first pixel in frame
    
end

%All column vectors
fields = fieldnames(stackInfo);
for i = 1:numel(fields)
    stackInfo.(fields{i}) = stackInfo.(fields{i})(:);
end

close(f);