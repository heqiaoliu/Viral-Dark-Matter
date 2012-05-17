function attachprmdlglistener(hObj, hDlg)
%ATTACHPRMDLGLISTENER Allow subclasses to attach listeners to the parameterdlg.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:10 $

l = handle.listener(hObj, hObj.findprop('Analyses'), ...
    'PropertyPostSet', {@lclresponses_listener, hDlg});
set(l, 'CallbackTarget', hObj);
setappdata(hDlg, 'tworesps_resps_listener', l);

% -------------------------------------------------------------------------
function lclresponses_listener(hObj, eventData, hDlg)

hObj.setupparameterdlg(hDlg);

% [EOF]
