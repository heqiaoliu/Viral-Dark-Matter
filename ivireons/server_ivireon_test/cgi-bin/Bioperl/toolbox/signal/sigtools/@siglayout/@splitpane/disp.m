function disp(this)
%DISP   Display this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:47:30 $

if this.AutoUpdate
    dispstr = 'true';
else
    dispstr = 'false';
end

disp(changedisplay(get(this), 'AutoUpdate', dispstr));

% [EOF]
