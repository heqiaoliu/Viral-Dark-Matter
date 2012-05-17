function d = diag(v,K)
%Embedded MATLAB Library Function

%   Limitations:
%       If supplied, argument K must be a real, scalar, integer value.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(ndims(v) == 2, 'First input must be 2D');
% Use isnumeric(v) instead of isa(v,'numeric') for backward compatibility:
% this function already worked in most cases with fixedpoint, although with
% vector input it assumes that 0 is representable in the fixedpoint type.
eml_assert(isnumeric(v) || islogical(v) || ischar(v), ...
    'First input must be numeric, logical, or char.');
if nargin == 1
    k = zeros(eml_index_class);
else
    eml_prefer_const(K);
    eml_assert(eml_is_const(K) || eml_option('VariableSizing'), ...
        'K-th diagonal input must be a constant.');
    eml_lib_assert(isa(K,'numeric') && isscalar(K) && ...
        isreal(K) && K == floor(K), ...
        'EmbeddedMATLAB:diag:KmustBeRealIntScalar', ...
        'K-th diagonal input must be a real integer scalar.');
    k = cast(K,eml_index_class);
end
if eml_is_const(isvector(v)) && isvector(v)
    nv = cast(eml_numel(v),eml_index_class);
    if k < 0
        % Create matrix with v as |k|-th subdiagonal.
        m = eml_index_minus(nv,k);
        d = eml_expand(eml_scalar_eg(v),[m,m]);
        for j = 1:nv
            d(eml_index_minus(j,k),j) = v(j);
        end
    else
        % Create matrix with v as k-th superdiagonal.
        m = eml_index_plus(nv,k);
        d = eml_expand(eml_scalar_eg(v),[m,m]);
        for j = 1:nv
            d(j,eml_index_plus(j,k)) = v(j);
        end
    end
else % Matrix input.
    eml_lib_assert(~isvector(v), ...
        'EmbeddedMATLAB:diag:varsizedMatrixVector', ...
        'Vector input must have only one variable-length dimension.');
    m = cast(size(v,1),eml_index_class);
    n = cast(size(v,2),eml_index_class);
    if m == 0 || n == 0
        d = eml_expand(eml_scalar_eg(v),[0,0]);
    elseif k <= -m || k >= n
        d = eml_expand(eml_scalar_eg(v),[0,1]);
    else
        stride = eml_index_plus(m,1);
        if k < 0
            % Extract |k|-th subdiagonal.
            % i1 = 1 - k
            i1 = eml_index_minus(1,k);
            % i2 = i1 + stride*(min(n,m+k)-1)
            i2 = eml_index_plus(i1,eml_index_times(stride, ...
                eml_index_minus(min(n,eml_index_plus(m,k)),1)));
        else
            % Extract k-th superdiagonal.
            % i1 = 1 + k*m
            i1 = eml_index_plus(1,eml_index_times(k,m));
            % i2 = i1 + stride*(min(m,n-k)-1)
            i2 = eml_index_plus(i1,eml_index_times(stride, ...
                eml_index_minus(min(m,eml_index_minus(n,k)),1)));
        end
        d = v(i1:stride:i2).';
    end
end
