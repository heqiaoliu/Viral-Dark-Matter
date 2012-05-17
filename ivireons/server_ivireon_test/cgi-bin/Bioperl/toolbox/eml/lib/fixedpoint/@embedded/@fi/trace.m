function t = trace(a)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(ndims(a) == 2, 'First input must be 2D.');
% This simple implementation will require temporary storage for DIAG(A).
t = sum(diag(a));
