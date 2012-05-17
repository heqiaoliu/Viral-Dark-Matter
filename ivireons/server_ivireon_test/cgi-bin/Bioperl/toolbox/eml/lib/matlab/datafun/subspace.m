function theta = subspace(A,B)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ['Function ''subspace'' is not defined for values of class ''' class(A) '''.']);
eml_assert(isa(B,'float'), ['Function ''subspace'' is not defined for values of class ''' class(B) '''.']);
eml_lib_assert(size(A,1) == size(B,1) && ndims(A) == 2 && ndims(B) == 2, ...
    'EmbeddedMATLAB:inputSizeError', ...
    'Inputs must be 2D matrices with the same number of rows.');
% Force size(A,2) >= size(B,2). 
if size(A,2) < size(B,2)
    theta = eml_subspace(B,A);
else
    theta = eml_subspace(A,B);
end

%--------------------------------------------------------------------------

function theta = eml_subspace(A,B)
% Force:
% 1. Both A and B are 'single' or both are 'double'.
% 2. If A is complex, B is also complex.
% Maximum number of recursive calls is 2.
if isa(A,'single') && ~isa(B,'single')
    theta = eml_subspace(A,single(B));
    return
elseif ~isa(A,'single') && isa(B,'single')
    theta = eml_subspace(single(A),B);
    return
elseif ~isreal(A) && isreal(B)
    theta = eml_subspace(A,complex(B));
    return
end
% Compute orthonormal bases, using SVD in "orth" to avoid problems
% when A and/or B is nearly rank deficient.
[UA,ra] = modified_orth(A);
[UB,rb] = modified_orth(B);
m = size(A,1);
w = eml.nullcopy(eml_expand(eml_scalar_eg(UA,UB),[1,m]));
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
% Compute the projection the most accurate way, according to [1].
for k = ONE:ra
    % UB = UB - UA(:,k)*(UA(:,k)'*UB);
    % Step 1:  w(1:rb) = UA(1:m,k)'*UB(1:m,1:rb);
    for j = ONE:rb
        s = eml_conjtimes(UA(1,k),UB(1,j));
        for i = TWO:m
            s = s + eml_conjtimes(UA(i,k),UB(i,j));
        end
        w(j) = s;
    end
    % Step 2:  UB(1:m,1:rb) = U(1:m,1:rb) - UA(1:m,k)*w(1,1:rb)
    for j = ONE:rb
        for i = ONE:m
            UB(i,j) = UB(i,j) - UA(i,k)*w(j);
        end
    end
end
% UB(:,rb) is the working part of UB, but there is data in UB(:,rb+1:end).
% To compute norm(UB(:,1:rb)) without a constant rb, we just need to zero
% out these extra columns of UB and compute norm(UB).
for k = rb+1 : size(UB,2)
    UB(:,k) = 0;
end
nrmUB = norm(UB);
% Due to roundoff, nrmUB can be slightly larger than 1, so to prevent a
% spurious complex result, we trim off the excess.
if nrmUB > 1
    nrmUB = ones(class(UB));
end
theta = asin(nrmUB);

%--------------------------------------------------------------------------

function [U,r] = modified_orth(A)
% Modified ORTH function.  ORTH returns a variable-size array, but this
% version returns a guaranteed-size (size(U) = [size(A,1),min(size(A))])
% and an estimate r of the rank of A.  Note that U(:,j) for j > r is not
% set to zero but should be ignored.
[U,S] = svd(A,0);
r = zeros(eml_index_class);
if isempty(A)
    return
end
tol = length(A)*S(1)*eps(class(A));
for k = 1:min(size(A))
    if S(k,k) > tol
        r = eml_index_plus(r,1);
    else
        break
    end
end

%--------------------------------------------------------------------------
