function set_impulseresponse(this, oldImpulseResponse)
%SET_IMPULSERESPONSE   PostSet function for the 'impulseresponse' property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 21:27:11 $

impulseresponse = get(this, 'ImpulseResponse');

% Fix the filtertype if multirates cannot be designed.
if strcmpi(impulseresponse, 'iir')
    if ~strcmpi(this.FilterType, 'single-rate') && ...
            ~allowsMultirate(this)
        set(this, 'FilterType', 'single-rate')
    end
    
    % If we are designing a multiband filter we cannot use frequency
    % response and IIR together.
    if this.NumberOfBands > 0 && ...
            ~strcmp(this.ResponseType, 'amplitudes')
        set(this, 'ResponseType', 'Amplitudes');
    end
end

updateMethod(this);

% [EOF]
