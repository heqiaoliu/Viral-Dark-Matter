function ok(hDlg)
%OK The OK action for the Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:22:48 $

% If the dialog is not applied, apply it.
if get(hDlg,'isApplied')
    success = true;
else
    success = apply(hDlg);
end

if success,
    set(hDlg, 'Visible', 'Off');
end

% [EOF]
