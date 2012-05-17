function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:27:00 $

b = true;
hfdesign = getfdesign(Hd);
if ~strcmpi(get(hfdesign, 'Response'), 'nyquist')
    b = false;
    return;
end
set(this, 'Band', num2str(hfdesign.Band));

abstractnyquist_setGUI(this, Hd);

% [EOF]
