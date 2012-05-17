function name = getFullName(this)
% GETFULLNAME Returns the unique full name of the object identified by THIS.
%
% NAME is a string (cell array of strings if THIS is an object array).
%
% ATTN: Model name is not part of the full name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:45 $

n = numel(this);

if n == 1
  name = '';
else
  name = cell(n,1);
  name(:) = {''};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
