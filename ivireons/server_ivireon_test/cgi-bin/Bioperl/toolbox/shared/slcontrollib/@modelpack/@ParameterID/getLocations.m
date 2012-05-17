function names = getLocations(this)
% GETLOCATIONS Returns the full names of the objects that use the parameter
% identified by THIS.
%
% NAMES is a cell array of strings (cell array of cell arrays if THIS is an
% object array).
%
% ATTN: Model name is not part of the location names.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:22 $

n = numel(this);

if n == 1
  names = {};
else
  names = cell(n,1);
  names(:) = {{}};
end


warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
