function status = isall(nlobj, cname)
%ISALL True if any element of the object array belongs to a given class.
%
%  ISALL(OBJ,'class_name') returns True if all elements of the object array
%  OBJ belong to the class, or a sub-class of, 'class_name'.
%
%  This function, @idnlfunVector/isall, is in use for an
%  heterogeneous array of nonlinearity estimator objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:38 $

% Author(s): Qinghua Zhang

status = true; 
 
for k=1:numel(nlobj.ObjVector)
  if ~isa(nlobj.ObjVector{k}, cname)
    status = false;
    return
  end
end

% FILE END
