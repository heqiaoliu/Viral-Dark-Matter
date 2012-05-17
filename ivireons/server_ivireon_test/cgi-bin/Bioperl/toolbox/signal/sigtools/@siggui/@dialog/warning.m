function warning(hDlg, Title)
%WARNING Manager for dialog warnings

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:21:32 $

if nargin == 1,
    Title = 'Warning';
end

% Create a warning and save its handle to be deleted later
h = get(hDlg, 'DialogHandles');
h.warn(end+1) = warndlg(lastwarn, Title);
set(hDlg, 'DialogHandles', h);

% [EOF]
