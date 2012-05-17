function error(hFDA, lstr)
%ERROR  FDATool's modal error dialog box.
%   ERROR(hFDA) FDATool's modal error dialog box.  It displays a
%   cleaned up version of lasterr.  It also resets the mouse pointer
%   and the status line.

%   Author(s): J. Schickler & P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2008/05/31 23:28:37 $ 

% Reset mouse pointer and status line.
status(hFDA, 'Ready');

if nargin == 1,
    ME = MException.last;
    lstr = ME.message;
end

siggui_error(hFDA, 'FDATool Error', lstr);

% [EOF]
