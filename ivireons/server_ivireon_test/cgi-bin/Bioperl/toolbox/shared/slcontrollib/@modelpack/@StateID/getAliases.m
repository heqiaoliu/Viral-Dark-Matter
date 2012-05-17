function aliases = getAliases(this)
% GETALIASES Returns the aliases for the individual elements of the state
% identified by THIS.  For unnamed states, an empty string should be returned
% in the cell array.
%
% ALIASES is a cell array of strings (cell array of cell arrays if THIS is an
% object array).  The list of aliases is a flat list whose length matches the
% total number of states.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:21 $

n = numel(this);

if n == 1
  aliases = {};
else
  aliases = cell(n,1);
  aliases(:) = {{}};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
