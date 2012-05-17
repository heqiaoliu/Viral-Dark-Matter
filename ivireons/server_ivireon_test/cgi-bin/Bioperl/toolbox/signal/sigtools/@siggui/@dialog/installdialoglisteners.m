function installdialoglisteners(hDlg)
%INSTALLDIALOGLISTENERS Installs the listener on the isApplied property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:21:11 $

isApp = hDlg.findprop('isApplied');

% Install the default listeners
hListen = handle.listener(hDlg, isApp, 'PropertyPostSet', @isapplied_listener);

set(hListen, 'CallbackTarget', hDlg);
set(hDlg, 'DialogListeners', hListen);

% [EOF]
