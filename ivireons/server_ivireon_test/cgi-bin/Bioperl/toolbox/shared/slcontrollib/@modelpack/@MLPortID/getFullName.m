function name = getFullName(this)
% GETFULLNAME Returns the unique full name of the port identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:41 $

name = get(this, 'Name');
