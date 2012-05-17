function isapplied_listener(hDlg, eventData)
%ISAPPLIED_LISTENER Listener to the isApplied property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:21:08 $

isApplied = get(hDlg, 'isApplied');
h         = get(hDlg, 'DialogHandles');
enabState = get(hDlg, 'Enable');

% If the dialog has just been applied, reset the transaction and disable.
% the Apply button
if isApplied,
    enabState = 'off';
end

set(h.apply,'Enable',enabState);

% [EOF]
