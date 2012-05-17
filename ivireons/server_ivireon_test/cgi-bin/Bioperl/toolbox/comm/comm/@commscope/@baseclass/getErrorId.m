function errorId = getErrorId(h)
%GETERRORID Create error Id based on objects class

%   @commscope\@baseclass

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:01:56 $

errorId = sprintf('comm:%s', regexprep(class(h), '\.', ':'));

%--------------------------------------------------------------------
% [EOF]
