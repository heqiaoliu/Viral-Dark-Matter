function N = numProps(this)
%NUMPROPS Return number of child properties.
%  NUMPROPS(H) returns number of chidl properties contained
%  in property database.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:46:41 $

N = iterator.numImmediateChildren(this);

% [EOF]
