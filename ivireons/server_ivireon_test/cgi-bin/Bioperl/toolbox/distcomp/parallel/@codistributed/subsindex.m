function idx = subsindex(idx)
%SUBSINDEX Subscript index for codistributed array
%   
%   OUTIDX = SUBSINDEX(INIDX) accepts a codistributed input INIDX, and returns the 
%   index OUTIDX of zero-based integer values for use in indexing.  The 
%   class of OUTIDX is the same as the underlying class of INIDX.  
%   
%   See also CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:45 $

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('subsindex', idx); %#ok<DCUNK> private static

if islogical(getLocalPart(idx))
   idx = gather(find(idx)-1);
else
   idx = gather(idx-1);
end
