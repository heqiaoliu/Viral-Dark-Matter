function f = findType(hMessageLog,mType)
%FINDTYPE Find all messages of chosen type from message log.
%  findType(H,TYPE) finds all messages of type TYPE from log
%  using case-independent matching of string CAT.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:40 $

% Case-independent:
f = find(cacheMergedLog(hMessageLog), ...
    '-function','Type', @(x)strcmpi(x,mType));

% [EOF]
