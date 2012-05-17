function status = isall(obj, cname)
%ISALL True if all elements of the object array belong to a given class.
%
%  ISALL(OBJ,'class_name') returns True if all elements of the object array
%  OBJ belong to the class, or a sub-class of, 'class_name'.
%
%  This function, @idnlfun/isall, is in use for a scalar object or for an
%  homogeneous array of objects (of a sub-class of idnlfun). The
%  heterogeneous array case is overloaded by @idnlfunVector/isall.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:11 $

% Author(s): Qinghua Zhang

status = isa(obj, cname);

% FILE END
