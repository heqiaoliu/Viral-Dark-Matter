function b = setGUI(this, Hd)
%SETGUI   Set the GUI

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:03:29 $

b = true;
hfdesign = getfdesign(Hd);

switch get(hfdesign, 'Response')
    case 'Pulse Shaping'
        pulseShape = hfdesign.PulseShape;
    case {'Raised Cosine', 'Gaussian', 'Square Root Raised Cosine'}
        pulseShape = hfdesign.Response;
    otherwise
        b = false;
        return;
end

hfmethod = getfmethod(Hd);

set(this, ...
    'PulseShape', pulseShape, ...
    'SamplesPerSymbol', num2str(hfdesign.SamplesPerSymbol), ...
    'Structure', convertStructure(this, hfmethod.FilterStructure));

astopProp = 'Astop';
if strcmp(pulseShape, 'Square Root Raised Cosine')
    astopProp = 'AstopSQRT';
end

switch hfdesign.Specification
    case 'Ast,Beta'
        set(this, ...
            'OrderMode2', 'Minimum', ...
            'Beta',    num2str(hfdesign.RolloffFactor), ...
            astopProp, num2str(hfdesign.Astop));
    case 'Nsym,Beta'
        set(this, ...
            'OrderMode2', 'Specify symbols', ...
            'NumberOfSymbols', num2str(hfdesign.NumberOfSymbols), ...
            'Beta',            num2str(hfdesign.RolloffFactor));
    case 'N,Beta'
        set(this, ...
            'OrderMode2', 'Specify order', ...
            'Order', num2str(hfdesign.FilterOrder), ...
            'Beta',  num2str(hfdesign.RolloffFactor));
    case 'Nsym,BT'
        set(this, ...
            'OrderMode2', 'Specify symbols', ...
            'NumberOfSymbols', num2str(hfdesign.NumberOfSymbols), ...
            'BT',              num2str(hfdesign.BT));
    otherwise
        error(generatemsgid('IncompleteConstraints'), ...
            'Internal Error: Lowpass ''%s'' incomplete', hfdesign.Specification);
end

abstract_setGUI(this, Hd);

% [EOF]
