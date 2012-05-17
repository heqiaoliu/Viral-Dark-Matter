function flag = isOpenLoop(this)
% ISOPENLOOP Returns the open-loop status of the signal marked as a
% linearization I/O.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:54:25 $

flag = get(this, 'OpenLoop');
