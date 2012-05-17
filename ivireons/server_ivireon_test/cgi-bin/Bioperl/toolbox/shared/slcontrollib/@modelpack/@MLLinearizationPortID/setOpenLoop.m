function setOpenLoop(this, flag)
% SETOPENLOOP Sets the open-loop status of the signal marked as a
% linearization I/O.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:28 $

warning('modelpack:MLLinearizationPortID', ...
        'Linearization port loop opening cannot be changed.');
