function name_listener(hDlg, hPrm)
%NAME_LISTENER Listener to the title property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:12:20 $

set(hDlg.FigureHandle, 'Name', hDlg.Name);

% [EOF]
