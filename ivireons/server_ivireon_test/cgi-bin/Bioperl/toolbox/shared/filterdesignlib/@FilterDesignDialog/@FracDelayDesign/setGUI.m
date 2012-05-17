function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/23 19:01:53 $

b = true;
hfdesign = getfdesign(Hd);
if ~(strcmpi(get(hfdesign, 'Response'), 'farrow fractional delay') || ...
    strcmpi(get(hfdesign, 'Response'), 'fractional delay'))
    b = false;
    return;
end

set(this, ...
    'FracDelay', num2str(hfdesign.FracDelay), ...
    'Order',     num2str(hfdesign.FilterOrder));

abstract_setGUI(this, Hd);


% [EOF]
