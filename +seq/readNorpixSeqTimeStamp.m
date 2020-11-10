function [tnum,tstr]=readNorpixSeqTimeStamp( varargin )
%T=READNORPIXSEQGIMESTAMP(norpixSEQfile,startFrame,[endFrame])
%
% Output:
%    tnum - number of seconds from midnight
%    tstr - time stamp string (dd-MMM-YYYY HH:MM:SS-UTC:ms us
%            ms: milliseconds, us: microseconds

% Azim Jinha 2020-11-10

p = inputParser;
p.addRequired('seq_file_name',@(x)isfile(x));
p.addOptional('StartFrame',1,@isnumeric);
p.addOptional('EndFrame',NaN,@isnumeric);
p.addParameter('SeqHeader',struct.empty,@isstruct);
p.addParameter('endianType','ieee-le',@(x)strcmpi(x,'ieee-le')|strcmpi(x,'ieee-be'));
p.parse(varargin{:});
Results=p.Results;


if isnan(Results.EndFrame), Results.EndFrame=Results.StartFrame; end
if isempty(Results.SeqHeader), Results.SeqHeader=seq.readNorpixSeqHeader(Results.seq_file_name); end

switch Results.SeqHeader.imageBitDepthReal
    case 8
        bitsPerPixel=8;
    case {12,14,16}
        bitsPerPixel=16;
    otherwise
        errror('seq:readNorpixTimestamp:wrongBitDepth',['Unsupported bit depth: ' num2str(SeqHeader.imageBitDepthReal)]);
end

bitsPerByte=8;
bytesPerPixel=bitsPerPixel/bitsPerByte;
bytesInFrame = Results.SeqHeader.imageWidth*Results.SeqHeader.imageHeight*bytesPerPixel;
%% open file and read data

fid = fopen(Results.seq_file_name,'r',Results.endianType);
clnFCN = onCleanup(@()fclose(fid));


nframes = Results.EndFrame-Results.StartFrame+1;
tstr(nframes,1)="";
tnum=zeros(nframes,1);
for read_idx=1:nframes
    frameNumber = (read_idx-1)+Results.StartFrame; % -1 takes care of off-by-one-error
    priorFrameBytes = (frameNumber-1)*Results.SeqHeader.TrueImageSize; % -1 takes care of off-by-one-error
    
    fpos_bytes = Results.SeqHeader.HeaderSize ... %header size
               + priorFrameBytes ... % number of bytes in previous frames
               + bytesInFrame; % number of bytes in current frame

    fseek(fid,fpos_bytes,'bof');
    [tnum(read_idx), tstr(read_idx,1)]=seq.extractTimeStamp(fid);
end