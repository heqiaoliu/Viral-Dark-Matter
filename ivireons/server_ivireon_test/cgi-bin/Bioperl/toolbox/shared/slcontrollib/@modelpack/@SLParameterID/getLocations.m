function locations = getLocations(this)
% GETLOCATIONS Returns the full names of the objects that use the parameter
% identified by THIS.
%
% ATTN: Model name is not part of the location names.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:28 $

locations = get(this, 'Locations');
