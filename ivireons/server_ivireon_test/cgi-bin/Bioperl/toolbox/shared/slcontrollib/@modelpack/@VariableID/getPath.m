function path = getPath(this)
% GETPATH Returns the relative path to the object identified by THIS.
%
% PATH is a string (cell array of strings if THIS is an object array).
%
% ATTN: Model name is not part of the path name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:47 $

n = numel(this);

if n == 1
  path = '';
else
  path = cell(n,1);
  path(:) = {''};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
