function this = loadobj(s)
%LOADOBJ  Load this object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/02/20 01:23:29 $

% This class is used to bridge between @fdfmethod and @fmethod so that the
% filter/fdatool session (using fedesign) saved in releases up to 7b can be
% loaded back in 8a. (see g431066)
this = fdfmethod.firlshbordntw;
set(this,rmfield(s,'DesignAlgorithm'));


% [EOF]
