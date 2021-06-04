function [ imgOut, timestamp ] = readNorpixSeqImage( varargin )
%READNORPIXSEQIMAGE reads images from a Norpix SEQ file
%[img,timestamp] = READNORPIXSEQIMAGE(norpixSEQfile,startFrame,endFrame)
% StartFrame and EndFrame are optional.

% Adapted from Norpix2MATLAB by
% Brett Shoelson, PhD <brett.shoelson@mathworks.com>

% Azim Jinha <ajinha@ucalgary.ca>
% 19 March 2013

% 20 April 2020
%  -extracted into a package
%  -added input parsing

% parse inputs and validate
p = inputParser;
p.addRequired('seq_file_name',@isfile);
p.addOptional('StartFrame',1,@isnumeric);
p.addOptional('EndFrame',NaN,@isnumeric);
p.addParameter('SeqHeader',struct.empty,@isstruct);
p.addParameter('endianType','ieee-le',@(x)strcmpi(x,'ieee-le')|strcmpi(x,'ieee-be'));
p.parse(varargin{:});

% Extract parameters
seq_file_name = p.Results.seq_file_name;
StartFrame = p.Results.StartFrame;
EndFrame = p.Results.EndFrame;
SeqHeader = p.Results.SeqHeader;
endianType=p.Results.endianType;

if isnan(EndFrame), EndFrame = StartFrame; end

if isempty(SeqHeader)
    SeqHeader = seq.readNorpixSeqHeader(seq_file_name);
end

switch SeqHeader.imageBitDepthReal
    case 8
        bitstr = 'uint8';
    case {12,14,16}
        bitstr = 'uint16';
    otherwise
        error('myofiber:readNorpixSeqImage:wrongBitDepth',['Unsupported bit depth: ' num2str(SeqHeader.imageBitDepthReal)])
end


fid = fopen(seq_file_name,'r',endianType);
clnFCN = onCleanup(@()fclose(fid));
frameRange = [StartFrame EndFrame];


nread = 0;
nFrames = frameRange(2)-frameRange(1)+1;

imgOut = cast(zeros(SeqHeader.imageHeight,SeqHeader.imageWidth,nFrames),bitstr);

timestamp(nFrames,1) = "";

%previousFractionSecond = 0;
%nSeconds = 0;

while nread<nFrames

    frameNumber = nread + frameRange(1)-1;
    frame_pos = SeqHeader.HeaderSize + ...
        (frameNumber * SeqHeader.TrueImageSize);

    fseek(fid,frame_pos,'bof');


    switch SeqHeader.ImageFormat
        case 'Monochrome'
            tmpImage = fread(fid, [SeqHeader.imageWidth ,SeqHeader.imageHeight], [bitstr '=>' bitstr]);
        otherwise
            disp("Cannot read file: " + seq_file_name);
            error('readNorpixSeqImage:UnknownFormat', ...
                "Reading image format `" + SeqHeader.ImageFormat + ...
                "` is NOT implemented yet")
    end

    % max(tmp(:))
    if isempty(tmpImage)
        break
    end
    imgOut(:,:,nread+1) = tmpImage';
    
    
    timestamp(nread+1,1)=seq.extractTimeStamp(fid);

    nread = nread + 1; % Post increment nread
end


if nread<nFrames
    warning('myofiber:readNorpixSeqImage:incompleteSeq', ...
        ['Number of frames read (', num2str(nread),') was less then' ...
        ' expected number of frames to be read (' num2str(nFrames) ').']);
end

end

