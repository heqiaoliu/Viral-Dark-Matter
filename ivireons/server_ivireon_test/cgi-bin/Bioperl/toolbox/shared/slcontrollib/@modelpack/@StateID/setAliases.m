function setAliases(this, aliases)
% SETALIASES Sets the aliases for the individual elements of the state
% identified by THIS.
%
% ALIASES is a cell array of strings.  A single string can be used to assign
% the same alias to each state.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/09/30 00:25:25 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
