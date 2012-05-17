function aliases = getAliases(this)
% GETALIASES Returns the aliases for the individual elements of the port
% identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:38 $

aliases = get(this, 'Aliases');
