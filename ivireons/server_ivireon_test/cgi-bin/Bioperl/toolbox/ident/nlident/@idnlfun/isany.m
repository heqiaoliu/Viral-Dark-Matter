function status = isany(obj, cname)
%ISANY True if any element of the object array belongs to a given class.
%
%  ISANY(OBJ,'class_name') returns true if any element of the object array
%  OBJ is of the class, or of a sub-class of, 'class_name'.
%
%  This function, @idnlfun/isany, is in use for a scalar object or for an
%  homogeneous array of objects (of a sub-class of idnlfun). The
%  heterogeneous array case is overloaded by @idnlfunVector/isany.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:12 $

% Author(s): Qinghua Zhang

status = isa(obj, cname);

% FILE END
