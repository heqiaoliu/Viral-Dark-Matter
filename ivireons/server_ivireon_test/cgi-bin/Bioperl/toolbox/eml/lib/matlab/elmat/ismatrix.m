function p = ismatrix(x)
%Embedded MATLAB Library Function

%   Copyright 2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
p = (ndims(x) == 2);
% Later, when we support MCOS objects that can override SIZE, we may 
% need to check:
% (size(x,1) >= 0) && (floor(size(x,1)) == size(x,1)) && ...
% (size(x,2) >= 0) && (floor(size(x,2)) == size(x,2))
