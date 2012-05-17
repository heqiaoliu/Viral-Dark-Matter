function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:03:15 $

b = true;
hfdesign = getfdesign(Hd);
if ~strcmpi(hfdesign.Response, 'cic')
    b = false;
    return;
end

set(this, 'DifferentialDelay', num2str(hfdesign.DifferentialDelay));

switch hfdesign.Specification
    case 'Fp,Ast'
        set(this, ...
            'Fpass', num2str(hfdesign.Fpass), ...
            'Astop', num2str(hfdesign.Astop));
    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: CIC ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

% [EOF]
