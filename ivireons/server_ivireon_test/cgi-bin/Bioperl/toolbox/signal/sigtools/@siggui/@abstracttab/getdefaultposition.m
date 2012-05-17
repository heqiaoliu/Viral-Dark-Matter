function defaultposition = getdefaultposition(this)
%GETDEFAULTPOSITION   Returns the default position for the tabs.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:21:43 $

sz = gui_sizes(this);
defaultposition = [10 10 300 200]*sz.pixf;

% [EOF]
