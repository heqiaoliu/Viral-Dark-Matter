function errorId = getErrorId(h)
%GETERRORID Create error Id based on objects class

%   @fec\@algbase

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:21:56 $

errorId = sprintf('comm:%s', regexprep(class(h), '\.', ':'));

%--------------------------------------------------------------------
% [EOF]
