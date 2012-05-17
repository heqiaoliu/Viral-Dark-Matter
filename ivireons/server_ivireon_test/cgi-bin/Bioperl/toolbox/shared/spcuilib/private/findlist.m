function [listsize,msg] = findlist(fid,listtype)
%FINDLIST find LIST in AVI
%   [LISTSIZE,MSG] = FINDLIST(FID,LISTTYPE) finds the LISTTYPE 'LIST' in
%   the file represented by FID and returns LISTSIZE, the size of the LIST,
%   and MSG. If the LIST is not found, MSG will contain a string with an
%   error message, otherwise MSG is empty.  Unknown chunks in the AVI file
%   are ignored. 

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:03:13 $


% Search for the LIST, ignore unknown chunks
found = -1;
while(found == -1)
  [chunk,msg] = findchunk(fid,'LIST');
  if ~isempty(msg)
      error('spcuilib:findlist:invalidChunk', msg);
  end
  [checktype,msg] = readfourcc(fid);
  if ~isempty(msg)
      error('spcuilib:findlist:invalidFourCharacterCode', msg);
  end
  if (checktype == listtype)
    listsize = chunk.cksize;
    break;
  else
    fseek(fid,-4,0); %Go back so we can skip the LIST
    msg = skipchunk(fid,chunk); 
    if ~isempty(msg)
        error('spcuilib:findlist:invalidChunk', msg);
    end
  end
  if ( feof(fid) ) 
    msg = sprintf('LIST ''%s'' did not appear as expected',listtype);
    listsize = -1;
  end
end
