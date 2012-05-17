function aliases = getAliases(this)
% GETALIASES Returns the aliases for the individual elements of the port
% identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:53:21 $

aliases = get(this, 'Aliases');
