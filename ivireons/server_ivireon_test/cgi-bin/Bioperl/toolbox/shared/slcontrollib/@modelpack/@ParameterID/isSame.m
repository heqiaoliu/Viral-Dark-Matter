function flag = isSame(this, ID)
% ISSAME Default implementation for determining whether a given ParameterID
% object identifies the same object as THIS.  Equivalent to operator
% overloading for "==".

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:23 $

flag = false;

if (length(this(:)) == length(ID(:))) && ...
      isa(ID, class(this)) && ...
      all( strcmp(ID.getFullName, this.getFullName) ) && ...
      isequal(ID.getDimensions, this.getDimensions) && ...
      all( strcmp(ID.getClass, this.getClass) )
  flag = true;
end
