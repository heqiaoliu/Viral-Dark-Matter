function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:03:25 $

b = true;

hfdesign = getfdesign(Hd);
if ~strncmp(get(hfdesign, 'Response'), 'Octave and Fractional Octave', 28)
    b = false;
    return;
end

set(this, 'BandsPerOctave', num2str(hfdesign.BandsPerOctave),...
    'Order', num2str(hfdesign.FilterOrder), ...
    'F0', num2str(hfdesign.F0));

abstract_setGUI(this, Hd);

% [EOF]
