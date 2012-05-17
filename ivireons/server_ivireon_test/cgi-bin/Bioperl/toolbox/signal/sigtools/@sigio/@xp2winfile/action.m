function success = action(hCD)
%ACTION Perform the action of exporting to a window text-file.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:27:56 $

winwrite(array(hCD.data));

success = true;

% [EOF]
