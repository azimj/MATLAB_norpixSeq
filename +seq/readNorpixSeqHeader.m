function headerInfo = readNorpixSeqHeader(varargin)
% NorpixSeqHeader
% Retreive header information from a Norpix image sequence (*.seq) 
%  

% Adapted from Norpix2MATLAB 
% Originally written 04/08/08 
% By Brett Shoelson, PhD <brett.shoelson@mathworks.com> 

% Azim Jinha <ajinha@ucalgary.ca>
% 18 March 2013
%
% 22 Nov 2017:
%    Norpix file formats>5 have a different header size. Updated to reflect
%    the change in header size.

% 20 April 2020:
%    Updating to work in a MATLAB +package folder
%    Added input parsing

% Header byte description offset,bytes,type
OFB.Version = {28,1,'long'};
OFB.HeaderSize = {32,4/4,'long'};
OFB.DescriptionFormat = {592,1,'long'};
OFB.Description = {36,512,'ushort'};
OFB.imageWidth = {548,1,'uint32'}; % 1
OFB.imageHeight = {548+4*1,1,'uint32'}; % 2
OFB.imageBitDepth = {548+4*2,1,'uint32'}; % 3
OFB.imageBitDepthReal = {548+4*3,1,'uint32'}; % 4
OFB.imageSizeBytes = {548+4*4,1,'uint32'}; % 5
OFB.imageFormatNumber = {548+4*5,1,'uint32'}; % 6
OFB.AllocatedFrames = {572,1,'ushort'};
OFB.Origin = {576,1,'ushort'};
OFB.TrueImageSize = {580,1,'ulong'};
OFB.FrameRate = {584,1,'double'};

%Parse inputs
p=inputParser;
p.addRequired('seq_file_name',@isfile)
p.parse(varargin{:})
seq_file_name = p.Results.seq_file_name;

% Open file as a IEEE-LE encoded file
fid = fopen(seq_file_name,'r','l');
clnFCN=onCleanup(@()fclose(fid));

% Read header fields
hdrFields = fieldnames(OFB);
for h = hdrFields'
    headerInfo.(h{1}) = readFile(fid,OFB.(h{1}));
end

% Hardcoded Header size for norpix file versions >=5
if  headerInfo.Version >=5
    warning('myofiber:readNorpixSeqHeader','Version 5+ detected, overriding reported header size')
    headerInfo.HeaderSize = 8192;
end
% Some post processing for image format
vals = [0,100,101,200:100:900];
fmts = {'Unknown','Monochrome','Raw Bayer','BGR','Planar','RGB',...
    'BGRx', 'YUV422', 'UVY422', 'UVY411', 'UVY444'};
flg_format = vals == headerInfo.imageFormatNumber;

headerInfo.ImageFormat = 'Unknown';
if any(flg_format)
    headerInfo.imageFormat = fmts{flg_format};
end

% post processing to extract description
if headerInfo.DescriptionFormat == 0 % Unicode
    headerInfo.Description = native2unicode(headerInfo.Description);
elseif headerInfo.DescriptionFormat == 1 % ASCII
    headerInfo.Description = char(headerInfo.Description);
end

end

function val = readFile(fid,readCell)
% READFILE
% reads file opened with file-id FID with the read specifications in
% cell readCell = {offset,bytes,format}.  
% To  read the UINT32 byte located at offset 548, 
%    readCell = {548,1,'uint32};
%

offset = 1;
bytes  = 2;
format = 3;

fseek(fid,readCell{offset},'bof');
val = fread(fid, ... 
            readCell{bytes}, ...
            readCell{format});
end
