function nlky = getcomp(nlobj, ky)
%GETCOMP get component of idnlfun object array.
%
%  nlky = getcomp(nlobj, ky)
%
% This function is to uniformly handle idnlfun/idnlfunVector objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:47:45 $

% Author(s): Qinghua Zhang

error(nargchk(2, 2, nargin,'struct'));

if isa(nlobj,'idnlfunVector')
  nlky = nlobj.ObjVector{ky};
else
  nlky = nlobj(ky);
end

% FILE END
