function enable_listener(hCoeff, eventData)
%ENABLE_LISTENER Overload to call update_labels

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:19:19 $

siggui_enable_listener(hCoeff, eventData);

if strcmpi(enabState, 'on'), update_labels(hCoeff); end

% [EOF]
