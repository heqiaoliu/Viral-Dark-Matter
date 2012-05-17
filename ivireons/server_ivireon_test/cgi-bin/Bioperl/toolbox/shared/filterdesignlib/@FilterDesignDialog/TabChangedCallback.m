function TabChangedCallback(hDlg, tag, tab)
%TABCHANGEDCALLBACK   

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/22 20:31:17 $

set(hDlg.getSource, 'ActiveTab', tab);

% [EOF]
