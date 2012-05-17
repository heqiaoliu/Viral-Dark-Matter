function errorId = getErrorId(h)
%GETERRORID Create error Id based on objects class

%   @doppler\@baseclass

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:41 $

errorId = sprintf('comm:%s', regexprep(class(h), '\.', ':'));

%--------------------------------------------------------------------
% [EOF]