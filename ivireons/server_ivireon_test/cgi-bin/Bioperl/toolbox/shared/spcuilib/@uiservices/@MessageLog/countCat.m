function y = countCat(hMessageLog,mCat)
%COUNTCAT Count all messages of chosen category from message log.
%  countCat(H,CAT) counts all messages of category CAT from log
%  using case-independent matching of string CAT.  Includes any
%  linked logs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:35 $

hMergedLog = cacheMergedLog(hMessageLog);
y = numel(findCat(hMergedLog,mCat));

% [EOF]
