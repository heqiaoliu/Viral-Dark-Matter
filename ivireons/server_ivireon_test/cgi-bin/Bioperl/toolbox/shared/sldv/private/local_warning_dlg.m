function local_warning_dlg(warnStr, dialogTitle)

%   Copyright 2006-2009 The MathWorks, Inc.
    if nargin<2
        dialogTitle = 'Simulink Design Verifier';        
    end
        
    warndlg(warnStr, dialogTitle);          