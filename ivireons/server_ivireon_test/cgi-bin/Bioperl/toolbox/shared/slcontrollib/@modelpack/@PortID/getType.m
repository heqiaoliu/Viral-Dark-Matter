function type = getType(this)
% GETTYPE Returns the I/O type of the port identified by THIS.
%
% TYPE is an enumerated string of type Model_IOType: 'Input' or 'Output'
% (cell array of strings if THIS is an object array).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:43 $

n = numel(this);

if n == 1
  type = '';
else
  type = cell(n,1);
  type(:) = {''};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
