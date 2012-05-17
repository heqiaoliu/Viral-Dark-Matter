function name = getName(this)
% GETNAME Returns the name of the variable.
%
% NAME is a string (cell array of strings if THIS is an object array).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/09/30 00:25:54 $

n = numel(this);

if n == 1
  name = '';
else
  name = cell(n,1);
  name(:) = {''};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
