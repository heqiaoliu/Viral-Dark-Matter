function update_checkbox(hCoeff, eventData)
%UPDATE_CHECKBOX update the sos checkbox

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/19 14:14:29 $

indx = getindex(hCoeff);

str  = get(hCoeff, 'AllStructures');

enabState = get(hCoeff, 'Enable');

h = get(hCoeff, 'Handles');

if strcmpi(enabState, 'on') & ~str.supportsos(indx),
    enabState = 'off';
end

set(h.sos, 'Enable', enabState);

% [EOF]
