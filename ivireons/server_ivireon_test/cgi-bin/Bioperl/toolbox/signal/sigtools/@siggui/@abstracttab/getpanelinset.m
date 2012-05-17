function paneloffset = getpanelinset(this)
%GETPANELINSET   Returns a 2 element vector for the panel offset.
%   GETPANELINSET(H) Returns a 2 element vector [x y w h] for the panel
%   offset.  Returns [0 0 0 0] by default.  Positive values are "insets"
%   negative values are "outsets"

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:21:44 $

sz = gui_sizes(this);

paneloffset = repmat(sz.ffs, 1, 4);

% [EOF]
