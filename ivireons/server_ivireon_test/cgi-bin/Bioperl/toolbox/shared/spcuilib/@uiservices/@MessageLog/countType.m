function y = countType(hMessageLog,mType)
%COUNTTYPE Count all messages of chosen type from message log.
%  countType(H,TYPE) counts all messages of type TYPE from log
%  using case-independent matching of string TYPE.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:36 $

y = numel(findType(cacheMergedLog(hMessageLog),mType));

% [EOF]
