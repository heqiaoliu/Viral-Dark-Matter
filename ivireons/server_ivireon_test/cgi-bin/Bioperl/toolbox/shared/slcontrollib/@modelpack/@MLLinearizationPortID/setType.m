function setType(this, type)
% SETTYPE Sets the linerization I/O type of the signal identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:29 $

warning('modelpack:MLLinearizationPortID', ...
        'Linearization port type cannot be changed.');
