function setLocations(this, names)
% SETLOCATIONS Sets the full names of the objects that use the parameter
% identified by THIS.
%
% NAMES is a cell array of strings.
%
% ATTN: Model name is not part of the location names.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/09/30 00:23:26 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
