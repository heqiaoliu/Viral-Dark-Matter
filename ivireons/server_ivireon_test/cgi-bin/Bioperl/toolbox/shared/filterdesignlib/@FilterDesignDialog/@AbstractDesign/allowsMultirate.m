function b = allowsMultirate(this)
%ALLOWSMULTIRATE   

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/27 21:26:57 $

if strcmpi(this.ImpulseResponse, 'fir')
    b = true;
else
    if isempty(this.FDesign);
        b = false;
    else
        state = getState(this);
        if strcmpi(state.FilterType, 'single-rate')
            state.FilterType = 'Decimator';
        end
        hfdesign = getFDesign(this, state);
        b = ~isempty(designmethods(hfdesign, 'iir'));
    end
end

% [EOF]
