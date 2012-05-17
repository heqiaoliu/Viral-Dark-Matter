function sz = eml_set_singleton_dim(sz,dim)
%Embedded MATLAB Private Function

%   Return the size vector SZ with SZ(DIM) set to 1.  This is used by 
%   various dimension-collapsing functions like SUM, PROD, VAR, etc. to
%   allow constant folding of the modified size vector.

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_prefer_const(dim);
if dim <= eml_numel(sz)
    sz(dim) = 1;
end
