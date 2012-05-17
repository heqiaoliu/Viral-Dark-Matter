function status = isany(nlobj, cname)
%ISANY True if any element of the object array is a given class.
%
%  ISANY(OBJ,'class_name') returns true if any element of the object array
%  OBJ is of the class, or of a sub-class of, 'class_name'.
%
%  This function, @idnlfunVector/isany, is in use for an
%  heterogeneous array of nonlinearity estimator objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:39 $

% Author(s): Qinghua Zhang

status = false; 
 
for k=1:numel(nlobj.ObjVector)
  if isa(nlobj.ObjVector{k}, cname)
    status = true;
    return
  end
end

% FILE END
