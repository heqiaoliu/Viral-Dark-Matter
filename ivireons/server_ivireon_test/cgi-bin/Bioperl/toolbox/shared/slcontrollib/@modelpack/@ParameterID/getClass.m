function cls = getClass(this)
% GETCLASS Returns the class of the value of the parameter identified by THIS.
%
% CLS is a string (cell array of strings if THIS is an object array).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:21 $

n = numel(this);

if n == 1
  cls = '';
else
  cls = cell(n,1);
  cls(:) = {''};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
