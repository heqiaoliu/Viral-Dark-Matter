function errorId = getErrorId(h)
%GETERRORID Create error Id based on objects class

%   @commsutils/@baseclass
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:20:00 $

errorId = sprintf('comm:%s', regexprep(class(h), '\.', ':'));

%--------------------------------------------------------------------
% [EOF]
