function  result = rcond(A)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(A,'float'), 'Inputs must be single or double.');
eml_lib_assert(ndims(A) == 2 && size(A,1) == size(A,2), 'MATLAB:square', ...
    'Matrix must be square.');
result = eml_rcond(A);