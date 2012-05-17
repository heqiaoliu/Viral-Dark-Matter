function help(hDlg)
%HELP Perform the action of the Help Push Button

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:18:55 $

warning(generatemsgid('GUIWarn'),'This dialog does not have custom help configured.  Loading helpdesk.');
helpdesk;

% [EOF]
