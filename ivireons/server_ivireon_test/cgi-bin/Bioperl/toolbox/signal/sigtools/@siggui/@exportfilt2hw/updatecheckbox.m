function updatecheckbox(hObj)
%UPDATECHECKBOX Update the checkbox

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:08:07 $

h = get(hObj, 'Handles');

enabState = get(hObj, 'Enable');
if strcmpi(enabState, 'on') & strcmpi(hObj.ExportMode, 'c header file'),
    enabState = 'off';
end

set(h.check, 'Value', hObj.DisableWarnings, 'Enable', enabState);

% [EOF]
