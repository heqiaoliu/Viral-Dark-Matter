function b = setGUI(this, Hd)
%SETGUI   Set the GUI.

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:03:17 $

b = true;
hfdesign = getfdesign(Hd);
if ~strcmpi(get(hfdesign, 'Response'), 'comb filter')
    b = false;
    return;
end
switch hfdesign.Specification
    case 'N,BW'
        set(this, ...
            'FrequencyConstraints', 'Quality Factor', ...
            'BW', num2str(hfdesign.BW));
    case 'N,Q'
        set(this, ...
            'FrequencyConstraints', 'Quality Factor', ...
            'Q', num2str(hfdesign.Q));
    case 'L,BW,GBW,Nsh'
        set(this, ...
            'OrderMode2', 'Number of Features', ...
            'NumPeaksOrNotches',  num2str(hfdesign.NumPeaksOrNotches), ...
            'BW', num2str(hfdesign.BW), ...
            'GBW', num2str(hfdesign.GBW), ...
            'ShelvingFilterOrder', num2str(hfdesign.ShelvingFilterOrder));
    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: Lowpass ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

set(this, 'OrderMode', 'specify');

% [EOF]
