function [e,cnt] = normest(S,tol)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(S,'float'), ...
    ['Function ''normest'' is not defined for values of class ''' class(S) '''.']);
eml_lib_assert(ndims(S) == 2, 'EmbeddedMATLAB:normest:inputMustBe2D', ...
    'Input matrix must be 2D.');
if nargin < 2
    tol = 1.e-6;
else
    eml_assert(isa(tol,'float'), ...
        ['Function ''normest'' is not defined for values of class ''' class(tol) '''.']);
    eml_assert(isreal(tol), 'Tolerance must be real.');
end
cnt = 0;
if eml_is_const(isvector(S)) && isvector(S)
    e = norm(S);
    return
end
ONE = ones(eml_index_class);
M = cast(size(S,1),eml_index_class);
N = cast(size(S,2),eml_index_class);
x = sum_abs_transpose(S);
e = norm(x);
if e == 0, return, end
x = eml_div(x,e);
e0 = zeros(class(S));
while abs(e-e0) > tol*e
    e0 = e;
    Sx = S*x;
    if is_all_zeros(Sx)
        for k = 1:eml_numel(Sx)
            Sx(k) = rand;
        end        
    end
    x = eml_xgemv('C',M,N,1,S,ONE,size(S,1),Sx,ONE,ONE,0,x,ONE,ONE);
    normx = norm(x);
    e = eml_rdivide(normx,norm(Sx));
    x = eml_div(x,normx);
    cnt = cnt + 1;
end

%--------------------------------------------------------------------------

function p = is_all_zeros(x)
% p = ~any(x) without ignoring NaNs.
eml_must_inline;
p = true;
for k = 1:eml_numel(x)
    if x(k) ~= 0
        p = false;
        return
    end
end

%--------------------------------------------------------------------------

function x = sum_abs_transpose(S)
% Calculate x = sum(abs(S),1)' efficiently.
eml_must_inline;
x = eml_expand(eml_scalar_eg(S),[size(S,2),1]);
for j = 1:size(S,2)
    for i = 1:size(S,1)
        x(j) = x(j) + abs(S(i,j));
    end
end

%--------------------------------------------------------------------------
