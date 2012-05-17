function p = eml_dim_to_fore_permutation(nd,dim)
%Embedded MATLAB Private Function

%   Returns a permutation vector p for permuting dimension DIM of an 
%   ND matrix to be the leading dimension.  This permutation shifts 
%   intervening dimensions to the right.

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_prefer_const(nd,dim);
ONE = ones(eml_index_class);
% Note that we handle the dim > ndims(x) case here
% with just the minimal special logic to limit the length of
% the permutation vector to a maximum of ndims(x)+1.  Our
% implementation of PERMUTE will call RESHAPE in this case.
d = min(cast(dim,eml_index_class),eml_index_plus(nd,ONE));
newndims = max(cast(nd,eml_index_class),d);
% Construct a permutation that will move the specified dimension to the 
% fore and shift the other dimensions to the right.
p = ONE:newndims;
p(1) = d;
for k = ONE:eml_index_minus(d,ONE)
    p(eml_index_plus(k,ONE)) = k;
end

%--------------------------------------------------------------------------
