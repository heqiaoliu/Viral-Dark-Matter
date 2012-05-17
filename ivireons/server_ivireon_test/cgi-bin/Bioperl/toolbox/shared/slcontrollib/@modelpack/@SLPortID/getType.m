function type = getType(this)
% GETTYPE Returns the type of the port identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:45 $

type = get(this, 'Type');
