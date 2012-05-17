function flag = isSame(this, ID)
% ISSAME Method to determine whether a given STParameterID
% object identifies the same object as THIS.  Equivalent to operator
% overloading for "==".
 
% Author(s): A. Stothert 09-Aug-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/09/30 00:25:15 $

flag = false;

if (length(this(:)) == length(ID(:))) && ...
      isa(ID, class(this)) && ...
      isequal(this.UniqueName,ID.UniqueName) && ...
      all( strcmp(ID.getFullName, this.getFullName) ) && ...
      isequal(ID.getDimensions, this.getDimensions) && ...
      all( strcmp(ID.getClass, this.getClass) )
  flag = true;
end
