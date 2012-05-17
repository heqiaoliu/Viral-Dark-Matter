function flag = isSame(this, ID)
% ISSAME Default implementation for determining whether a given
% SLLinearizationPortID object identifies the same object as THIS.
% Equivalent to operator overloading for "==".

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:54:26 $

flag = false;

if (length(this(:)) == length(ID(:))) && ...
      isa(ID, class(this)) && ...
      all( strcmp(ID.getFullName, this.getFullName) ) && ...
      isequal(ID.getDimensions, this.getDimensions) && ...
      all( strcmp(ID.getType, this.getType) ) && ...
      isequal(ID.isOpenLoop, this.isOpenLoop);
  flag = true;
end
