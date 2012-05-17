function b = blanks(n)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(isa(n,'numeric') && isscalar(n), 'Input must be numeric.');
b = eml_expand(' ',[1,n]);