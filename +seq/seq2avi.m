function seq2avi(varargin)
%seq2avi(seqFilePath) convert SEQ file to AVI save file in same folder but
%with AVI extension
%
%seq2avi(seqFilePath,outFilePath) specify an output file
%seq2avi(..., 'startFrame', 1) specify starting frame number (default `1`)
%seq2avi(..., 'endFrame', 5) specify end frame number (default startFrame+5)
%seq2avi(...,'outputFrameRate,inf) specify desired output frame rate if less than
%     SEQ frame rate.
%
% Converts SEQ file to AVI and adds blank frames if frames were dropped
% during recording

% Azim Jinha 2021-05-20
endFrameOffset = 5;

p=inputParser;
p.addRequired('seqFilePath',@mustBeFile);
p.addOptional('outFilePath','',@(s) ischar(s) || isstring(s));
p.addParameter('startFrame',1,@isscalar);
p.addParameter('endFrame',-1,@isscalar);
p.addParameter('outputFrameRate',inf,@isscalar);
p.parse(varargin{:});

outFilePath = p.Results.outFilePath;
if isempty(outFilePath)
    seq_extension_pattern = caseInsensitivePattern('.seq')+textBoundary('end');
    outFilePath = replace(p.Results.seqFilePath,seq_extension_pattern,'.avi');
end

endFrame = p.Results.endFrame;
startFrame = p.Results.startFrame;
outputFrameRate =p.Results.outputFrameRate;

if endFrame<startFrame
    endFrame = startFrame+endFrameOffset;
end



%%

seqheader = seq.readNorpixSeqHeader(p.Results.seqFilePath);
seqFrameRate = seqheader.FrameRate;

outputFrameRate = min(outputFrameRate,seqFrameRate);

skipFrames = round(seqFrameRate/outputFrameRate);

framesPerSec = 1/outputFrameRate;
%% Make sure end frame is less than number of frames in file
endFrame = min(endFrame,seqHeader.AllocatedFrames);





vr = VideoWriter(outFilePath,'Archival');
vr.FrameRate = seqFrameRate/skipFrames;

oncln = onCleanup(@()close(vr));
blankframe = ones(seqheader.imageHeight,seqheader.imageWidth,seqheader.imageBitDepthReal);

ts_prev = [];
for iFrame = startFrame:skipFrames:endFrame
    [curimage,ts_current] = seq.readNorpixSeqImage;
    
    % check if we have dropped frames (and blank frame for each dropped
    % frame)
    if ~isempty(ts_prev)
        diff_time = ts_current - ts_prev;
        if diff_time > framesPerSec + 2*eps
            numbmissing = floor(framesPerSec * diff_time);
            warning('seq2avi:missingFrames', ...
                "File is missing " + num2str(numbmissing,'%d') + ...
                " frames at time stamp: " + ...
                num2str(ts_prev) + " to " + num2str(ts_current));
            
            for i=1:numbmissing
                vr.writeVideo(blankframe);
            end
        end
    end
    vr.writeVideo(curimage);
    ts_prev = ts_current;

end

