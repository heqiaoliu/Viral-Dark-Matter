function success = action(hCD)
%ACTION Perform the action of exporting to a filter coefficient file.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/12/26 22:22:49 $

fcfwrite(array(hCD.data), [], hCD.Format(1:3));

success = true;

% [EOF]
