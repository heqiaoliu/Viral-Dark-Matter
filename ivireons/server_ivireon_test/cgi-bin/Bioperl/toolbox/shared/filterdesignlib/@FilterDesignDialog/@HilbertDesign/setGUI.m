function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 03:03:22 $

b = true;
hfdesign = getfdesign(Hd);
if ~any(strcmpi(get(hfdesign, 'Response'), {'hilbert', 'hilbert transformer'}))
    b = false;
    return;
end

switch hfdesign.Specification
    case 'N,TW'
        set(this, 'TransitionWidth', num2str(hfdesign.TransitionWidth));
    case 'TW,Ap'
        set(this, ...
            'TransitionWidth', num2str(hfdesign.TransitionWidth), ...
            'Apass',           num2str(hfdesign.Apass));
    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: Hilbert ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

% [EOF]
