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
p.parse(varargin{:});
Results=p.Results;


if isnan(Results.EndFrame), Results.EndFrame=Results.StartFrame; end
if isempty(Results.SeqHeader), Results.SeqHeader=seq.readNorpixSeqHeader(Results.seq_file_name); end

headerSizeBytes = Results.SeqHeader.HeaderSize;
endianType = Results.SeqHeader.endianType;
imageSizeBytes = Results.SeqHeader.imageSizeBytes;
%% open file and read data

fid = fopen(Results.seq_file_name,'r',endianType);
clnFCN = onCleanup(@()fclose(fid));


nframes = Results.EndFrame-Results.StartFrame+1;
tstr(nframes,1)="";
tnum=zeros(nframes,1);
for read_idx=1:nframes
    frameNumber = (read_idx-1)+Results.StartFrame; % -1 takes care of off-by-one-error
    framePos =  headerSizeBytes + ...
                (frameNumber-1)*Results.SeqHeader.TrueImageSize; % -1 takes care of off-by-one-error
    timeStampPos = framePos + imageSizeBytes;
    

    fseek(fid,timeStampPos,'bof');
    [tnum(read_idx), tstr(read_idx,1)]=seq.extractTimeStamp(fid);
end
