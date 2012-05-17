function hDlg = dialog(hFig)
%DIALOG Constructor for the dialog object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:21:17 $

if nargin < 1, hFig = -1; end

hDlg = siggui.dialog;

% [EOF]
