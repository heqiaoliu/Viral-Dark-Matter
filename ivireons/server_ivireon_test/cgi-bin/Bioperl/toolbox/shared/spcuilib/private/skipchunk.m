function [msg] = skipchunk(fid,chunk)
%SKIPCHUNK skip chunk in AVI
%   MSG = SKIPCHUNK(FID,CHUNK) skips CHUNK.cksize bytes in the AVI file
%   FID.  MSG contains an error message string if the skip fails, otherwise
%   it is an empty string.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:22:42 $

msg = '';
% Determine if pad byte is necessary
if ( rem(chunk.cksize,2) ) % If the chunk size is odd, there is a pad byte
  pad = 1;
else 
  pad = 0;
end

% Skip the chunk
status = fseek(fid,chunk.cksize + pad,0);
if ( status == -1 )
  msg = 'Incorrect chunk size information in AVI file.';
end
return;
