function seq2avi(varargin)
%seq2avi(seqFilePath) convert SEQ file to AVI save file in same folder but
%with AVI extension
%
%seq2avi(seqFilePath,outFilePath) specify an output file
%seq2avi(..., 'startFrame', 1) specify starting frame number (default `1`)
%seq2avi(..., 'endFrame', 5) specify end frame number (default startFrame+5)
%seq2avi(..., 'outputFrameRate,inf) specify desired output frame rate if less than
%     SEQ frame rate.
%seq2avi(..., 'fillMissing',true) if frames were dropped in initial recording ask user if they should be filled in
%seq2avi(..., 'videoProfile','Archival') see VideoWriter for valid values
%   default: 'Archival' Motion JPEG 2000 lossless compression.
%
% Converts SEQ file to AVI and adds blank frames if frames were dropped
% during recording.
%
% See also: VideoWriter

% Azim Jinha 2021-05-20



endFrameOffset = 5;

p=inputParser;
p.addRequired('seqFilePath',@mustBeFile);
p.addOptional('outFilePath','',@(s) ischar(s) || isstring(s));
p.addParameter('startFrame',1,@isscalar);
p.addParameter('endFrame',-1,@isscalar);
p.addParameter('outputFrameRate',inf,@isscalar);
p.addParameter('fillMissing',true,@islogical);
p.addParameter('videoPrfile','Archival')
p.parse(varargin{:});

outFilePath = p.Results.outFilePath;
if isempty(outFilePath)
    seq_extension_pattern = caseInsensitivePattern('.seq')+textBoundary('end');
    outFilePath = replace(p.Results.seqFilePath,seq_extension_pattern,'.avi');
end

endFrame = p.Results.endFrame;
startFrame = p.Results.startFrame;
outputFrameRate =p.Results.outputFrameRate;
fillMissing = p.Results.fillMissing;
videoProfile = p.Results.videoProfile;
if endFrame<startFrame
    endFrame = startFrame+endFrameOffset;
end



%%

seqHeader = seq.readNorpixSeqHeader(p.Results.seqFilePath);
endFrame = min(endFrame,seqHeader.AllocatedFrames);

seqFrameRate = seqHeader.FrameRate;

outputFrameRate = min(outputFrameRate,seqFrameRate);

skipFrames = round(seqFrameRate/outputFrameRate);

framesPerSec = outputFrameRate;
frameRate = 1/framesPerSec;
%% Make sure end frame is less than number of frames in file
endFrame = min(endFrame,seqHeader.AllocatedFrames);





vr = VideoWriter(outFilePath, videoProfile);
vr.FrameRate = seqFrameRate/skipFrames;
open(vr);
oncln = onCleanup(@()close(vr));
number_color_channels = 3;
blankframe = ones(seqHeader.imageHeight,seqHeader.imageWidth,number_color_channels);

ts_prev = [];
warning off
oncln_warn = onCleanup(@()warning('on'));
for iFrame = startFrame:skipFrames:endFrame
    if mod(iFrame,100)==0
        disp("pocessing frame: " + num2str(iFrame) + "/" + ...
            num2str(round((endFrame-startFrame)/skipFrames)))
    end
    [curimage,ts_current] = seq.readNorpixSeqImage(p.Results.seqFilePath,iFrame);
    c = class(curimage);
    if ~contains(c,{'single','uint8','double'})
        curimage = im2double(curimage);
    end
    switch size(curimage,3)
        case 1 % grey scale
            curimage_rgb = repmat(curimage,1,1,number_color_channels);
        case 3 % rgb
            curimage_rgb = curimage;
        otherwise
            error("frame size: " + num2str(size(curimage)) + " does not represent an image");
    end
    % check if we have dropped frames (and blank frame for each dropped
    % frame)
    
    if fillMissing && ~isempty(ts_prev)
        % maximum time between frames
        %ToDo: Need to check logic for filling in missing frames...
        max_frame_time = 2*framesPerSec*skipFrames;
        
        %time between current frame and last frame
        diff_time = ts_current - ts_prev;
        if diff_time > max_frame_time
            numbmissing = floor(framesPerSec * diff_time);
            warning('seq2avi:missingFrames', ...
                "File is missing " + num2str(numbmissing,'%d') + ...
                " frames at time stamp: " + ...
                num2str(ts_prev) + " to " + num2str(ts_current));
            
            % Ask to fill missing frames...
            fillAnswer=questdlg("Fill " + num2str(numbmissing) + " missing frames?", ...
                "Fill missing",'Yes','No','No');
            if isequal(fillAnswer,'Yes')
                for i=1:numbmissing
                    vr.writeVideo(blankframe);
                end
            end
        end
    end
    vr.writeVideo(curimage_rgb);
    ts_prev = ts_current;

end

