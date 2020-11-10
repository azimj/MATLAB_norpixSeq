function [tnum, tstr]=extractTimeStamp(fid)
%[Tnum,Tstr]=EXTRACTTIMESTAMP(FID)
%Reads time stamp at current position of open file: fid
% Output:
%    tnum - number of seconds from midnight
%    tstr - time stamp string (dd-MMM-YYYY HH:MM:SS-UTC:ms us
%            ms: milliseconds, us: microseconds

%Azim Jinha 2020-11-10

% POSIX time in seconds
timeSecsPOSIX=fread(fid,1,'int32');

% Convert to MATLAB reference
POSIX_EPOCH=datenum(1970,1,1);
secondsPerDay=24*60*60;
tmp3 = timeSecsPOSIX/secondsPerDay+POSIX_EPOCH;
subSeconds(1,:)=fread(fid,2,'uint16');
tstr=datestr(tmp3)+"-UTC:"+num2str(subSeconds);

daynum=floor(tmp3);

t_seconds=timeSecsPOSIX-(daynum-POSIX_EPOCH)*secondsPerDay;
miliseconds = sum(subSeconds.*10.^[-3 -6]);
tnum=t_seconds+miliseconds;
