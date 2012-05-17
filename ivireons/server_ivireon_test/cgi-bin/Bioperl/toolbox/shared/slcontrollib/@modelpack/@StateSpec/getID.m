function ID = getID(this)
% GETID Returns the handle of the identifier object associated with THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:29 $

ID = get(this, {'ID'});
ID = cat(1, ID{:});
