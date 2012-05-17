function path = getpath(p)
%GETPATH   Get the path.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:56:50 $

%the space affs a space to some paths but it puts a space where one is
%needed in others the latter case takes precedent
path = strrep(p, sprintf('\n'), ' ');

% [EOF]
