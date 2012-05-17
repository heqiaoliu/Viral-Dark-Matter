function nlobj = setcomp(nlobj, ky, nlky)
%GETCOMP set component of idnlfun object array.
%
% nlobj = setcomp(nlobj, ky, nlky)
%
% This function is to uniformly handle idnlfun/idnlfunVector objects.
% nlobj is a vector of objects.
% Set the ky-th component object of nlobj to nlky, no matter if 
% nlobj.ObjVector{ky} or nlobj(ky) should be used for indexing.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/11/09 16:24:02 $

% Author(s): Qinghua Zhang

error(nargchk(3, 3, nargin,'struct'));
error(nargoutchk(1, 1, nargout));

if isa(nlobj,'idnlfunVector')
  nlobj.ObjVector{ky} = nlky;
else
  nlobj(ky) = nlky;
end

% Oct2009
% FILE END
