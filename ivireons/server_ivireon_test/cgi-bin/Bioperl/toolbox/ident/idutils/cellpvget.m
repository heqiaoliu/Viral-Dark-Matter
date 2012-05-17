function value = cellpvget(c, prop)
%CELLPVGET get the same property of structures of objects in a cellarray
%
%  value = cellpvget(c, prop)
%
%Note: this function uses dynamic field name and nested function 

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:21:24 $

% Author(s): Qinghua Zhang

if isempty(c)
  value = {}; 
  return
end

value = cellfun(@DFNGet, c, 'UniformOutput', false);

  % Nested function, get property with Dynamic Field Name
  function v = DFNGet(a)
    v = a.(prop);
  end
end

% FILE END