function cleanup(this)
%CLEANUP  Remove the scope face, excluding menu, toolbar, and status bar.

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:42 $

% This function is required by the scope frame work

% Call unrender to remove the scope face
unrender(this);

%-------------------------------------------------------------------------------
% [EOF]
