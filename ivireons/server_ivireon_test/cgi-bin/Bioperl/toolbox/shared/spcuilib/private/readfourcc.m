function [rifftype,msg] = readfourcc(fid)
%READFOURCC read four character code
%   [RIFFTYPE,MSG] = READFOURCC(FID) returns a four character code RIFFTYPE
%   from the file represented by FID. If the desired amount of data was not
%   read, then MSG is a string containing an error message, otherwise MSG is
%   empty. 

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:22:41 $

msg = '';
[rifftype, count] = fread(fid,4,'uchar');
rifftype = char(rifftype)';
if (count ~= 4)
  msg= 'Error reading FOURCC. Invalid AVI file.';
end
return;
