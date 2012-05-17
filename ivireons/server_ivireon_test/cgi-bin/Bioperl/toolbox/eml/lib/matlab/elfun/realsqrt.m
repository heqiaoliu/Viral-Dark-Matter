function x = realsqrt(x)
%Embedded MATLAB Library Function

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''realsqrt'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isreal(x), 'Input must be real.');
for k = 1:eml_numel(x)
    if x(k) < 0
        eml_error('MATLAB:realsqrt:complexResult','Realsqrt produced complex result.');
    end
end
for k = 1:eml_numel(x)
    x(k) = eml_scalar_realsqrt(x(k));
end