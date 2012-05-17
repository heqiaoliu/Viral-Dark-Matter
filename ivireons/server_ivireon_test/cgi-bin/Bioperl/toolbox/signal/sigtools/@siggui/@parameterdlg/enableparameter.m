function enableparameter(hDlg, tag)
%ENABLEPARAMETER Enable a parameter on the parameter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:12:29 $

dparams = get(hDlg, 'DisabledParameters');

indx = find(strcmpi(tag, dparams));

if ~isempty(indx),
    dparams(indx) = [];
end

set(hDlg, 'DisabledParameters', dparams);

% [EOF]
