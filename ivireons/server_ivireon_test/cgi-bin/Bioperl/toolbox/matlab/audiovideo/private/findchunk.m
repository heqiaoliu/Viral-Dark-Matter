function [chunk,msg,msgID] = findchunk(fid,chunktype)
%FINDCHUNK find chunk in AVI
%   [CHUNK,MSG,msgID] = FINDCHUNK(FID,CHUNKTYPE) finds a chunk of type CHUNKTYPE
%   in the AVI file represented by FID.  CHUNK is a structure with fields
%   'ckid' and 'cksize' representing the chunk ID and chunk size
%   respectively.  Unknown chunks are ignored (skipped). 

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/07/26 19:30:47 $

chunk.ckid = '';
chunk.cksize = 0;
msg = '';
msgID='';

while( strcmp(chunk.ckid,chunktype) == 0 )
  [msg msgID] = skipchunk(fid,chunk);
  if ~isempty(msg)
    fclose(fid);
    error(msgID,msg);
  end
  [id, count] = fread(fid,4,'uchar');
  chunk.ckid = [char(id)]';
  if (count ~= 4 )
    msg = sprintf('''%s'' did not appear as expected.',chunktype);
    msgID = 'MATLAB:findchunk:unexpectedChunkType';
  end
  [chunk.cksize, count] = fread(fid,1,'uint32');
  if (count ~= 1)
    msg = sprintf('''%s'' did not appear as expected.',chunktype);
    msgID = 'MATLAB:findchunk:unexpectedChunkType';
  end
  if ( ~isempty(msg) ), return; end
end
return;
