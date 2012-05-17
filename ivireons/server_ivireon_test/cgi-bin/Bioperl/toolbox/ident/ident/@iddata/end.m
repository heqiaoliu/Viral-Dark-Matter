function endidx = end(dat,k,n)
%IDDATA/END returns the index of the last entry of a single-experiment
%    IDDATA object

%   Author: L. Ljung 23-10-03
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $   $Date: 2008/10/02 18:46:45 $

endidx = size(dat,k);
if length(endidx)>1
    ctrlMsgUtils.error('Ident:dataprocess:endCheck1')
end
