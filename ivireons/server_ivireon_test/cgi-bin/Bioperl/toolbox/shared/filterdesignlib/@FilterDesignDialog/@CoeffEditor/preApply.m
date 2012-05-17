function [b, str] = preApply(this, hDlg) %#ok<INUSD>
%PREAPPLY   Set the filter with the GUI's settings.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:24:30 $

b   = true;
str = '';

Hd = get(this, 'FilterObject');

names = coefficientnames(Hd);

oldValues = get(Hd, names);
try
    values = cell(size(names));
    for indx = 1:length(names)
        values{indx} = evaluatevars(get(this, sprintf('CoefficientVector%d', indx)));
    end
    
    pMem = get(this, 'PersistentMemory');
    
    if strcmpi(pMem, 'on')
        states = evaluatevars(get(this, 'States'));
    end
    
    set(Hd, names, values);
    set(Hd, 'PersistentMemory', strcmpi(pMem, 'on'));
    
    if strcmpi(pMem, 'on')
        set(Hd, 'States', states);
    end
    
    applySettings(this.FixedPoint, Hd);
catch e
    b = false;
    str = cleanerrormsg(e.message);
    set(Hd, names, oldValues);
end

% [EOF]
