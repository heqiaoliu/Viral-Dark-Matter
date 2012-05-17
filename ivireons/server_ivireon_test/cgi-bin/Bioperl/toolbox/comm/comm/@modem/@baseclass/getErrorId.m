function errorId = getErrorId(h)
%GETERRORID Create error Id based on objects class

%   @modem\@baseclass

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:49 $

errorId = sprintf('comm:%s', regexprep(class(h), '\.', ':'));

%--------------------------------------------------------------------
% [EOF]
