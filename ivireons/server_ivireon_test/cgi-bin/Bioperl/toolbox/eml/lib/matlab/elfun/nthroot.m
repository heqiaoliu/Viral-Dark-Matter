function y = nthroot(x,n)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ['Function ''nthroot'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isa(n,'float'), ['Function ''nthroot'' is not defined for values of class ''' class(n) '''.']);
eml_assert(isreal(x) && isreal(n), 'Both X and N must be real.'); % 'MATLAB:nthroot:ComplexInput'
y = eml_scalexp_alloc(eml_scalar_eg(x,n),x,n);
for k = 1:eml_numel(y)
    xk = eml_scalexp_subsref(x,k);
    nk = eml_scalexp_subsref(n,k);
    if xk < 0 && (nk ~= floor(nk) || rem(nk,2) == 0)
        eml_error('MATLAB:nthroot:NegXNotOddIntegerN', ...
            'If X is negative, N must be an odd integer.');
    else
        y(k) = eml_scalar_nthroot(xk,nk);
    end
end
