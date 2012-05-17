function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:23:09 $

b = true;
hfdesign = getfdesign(Hd);
if ~strcmpi(get(hfdesign, 'Response'), 'halfband')
    b = false;
    return;
end
abstractnyquist_setGUI(this, Hd);

% [EOF]
