function local_error_dlg(errStr, dialogTitle)

%   Copyright 2006-2009 The MathWorks, Inc.
    if nargin<2
        dialogTitle = 'Simulink Design Verifier';
    end
        
    errordlg(errStr, dialogTitle);          