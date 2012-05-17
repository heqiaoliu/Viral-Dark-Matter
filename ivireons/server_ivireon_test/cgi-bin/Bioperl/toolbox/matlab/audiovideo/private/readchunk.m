function chunk = readchunk(fid)
%READCHUNK read riff file chunk
%   CHUNK = READCHUNK(FID) reads a four character chunk ID and a 32-bit
%   integer chunk size into the 'ckid' and 'cksize' fields of CHUNK, from
%   the RIFF file associated with FID.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/07/26 19:31:00 $

msg = 'Chunk not read correctly';
msgID= 'MATLAB:readchunk:badChunkRead';

[id, count] = fread(fid,4,'uchar');
chunk.ckid = [char(id)]';
if (count ~= 4)
  error(msgID,msg);
end

[chunk.cksize, count] = fread(fid,1,'uint32');
if (count ~= 1)
  error(msgID,msg);
end
return;
