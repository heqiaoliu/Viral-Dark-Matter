function f = findCat(hMessageLog,mCat)
%FINDCAT Find all messages of chosen category from message log.
%  findCat(H,CAT) finds all messages of category CAT from log
%  using case-independent matching of string CAT.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/05/20 00:20:38 $

% Case-independent:
f = find(cacheMergedLog(hMessageLog), ...
    '-function','Category',@(x)strcmp(x,mCat));

% [EOF]
