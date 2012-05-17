function class = getClass(this)
% GETCLASS Returns the class of the value of the parameter identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:33 $

class = get(this, 'Class');
