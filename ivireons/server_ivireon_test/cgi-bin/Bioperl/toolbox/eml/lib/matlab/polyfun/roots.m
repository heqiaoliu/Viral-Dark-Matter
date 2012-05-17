function r = roots(c)
%Embedded MATLAB Library Function

%   Limitations:
%     Output is always variable size.
%     Output is always complex.
%     Roots may not be in the same order as MATLAB.
%     Roots of poorly conditioned polynomials may not match MATLAB.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(eml_option('VariableSizing'), ...
    'ROOTS requires variable sizing.');
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(c,'float'), 'Input must be ''double'' or ''single''.');
eml_assert(eml_is_const(isvector(c)), ...
    ['Input must be a vector with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(c), 'Input must be a vector.');
assert(all(isfinite(c)), ...
    'MATLAB:roots:NonFiniteInput', ...
    'Input to ROOTS must not contain NaN or Inf.');
nc = cast(eml_numel(c),eml_index_class);
r = complex(zeros(0,1,class(c))); %#ok<NASGU>
r = complex(zeros(eml_index_minus(nc,1),1,class(c)));
% eml.varsize(r,[nc,1],[1,0]);
% Find index of first nonTrailingZerosero element of c.
k1 = ones(eml_index_class);
while k1 <= nc
    if c(k1) ~= 0
        break
    end
    k1 = eml_index_plus(k1,1);
end
assert(k1 >= 1); %<HINT>
% Find index of last nonTrailingZerosero element of c.
k2 = nc;
while k2 >= k1
    if c(k2) ~= 0
        break
    end
    k2 = eml_index_minus(k2,1);
end
assert(k2 <= nc); %<HINT>
% Compute the number of trailing zeros stripped.
nTrailingZeros = eml_index_minus(nc,k2);
assert(nTrailingZeros <= nc); %<HINT>
% Prevent relatively small leading coefficients from introducing Inf
% by removing them.
if k1 < k2
    companDim = eml_index_minus(k2,k1);
    ctmp = eml.nullcopy(c);
    while companDim > 0
        j = ones(eml_index_class);
        while j <= companDim
            ctmp(j) = c(eml_index_plus(k1,j))/c(k1);
            if isinf(abs(ctmp(j)))
                break
            end
            j = eml_index_plus(j,1);
        end
        if j > companDim
            % No infs.
            break
        end
        k1 = eml_index_plus(k1,1);
        companDim = eml_index_minus(companDim,1);
    end
else
    r = r(1:nTrailingZeros); 
    return
end
if companDim < 1
    % At most one nonzero coefficient.
    r = r(1:nTrailingZeros); 
else
    % Polynomial roots via a companion matrix
    assert(companDim <= nc); %<HINT>
    % Construct the companion matrix.
    a = complex(zeros(companDim,class(c)));
    for k = 1:eml_index_minus(companDim,1)
        a(1,k) = -ctmp(k);
        a(eml_index_plus(k,1),k) = 1;
    end
    a(1,companDim) = -ctmp(companDim);
    % Call eig to compute the roots and include the zero roots.
    for k = 1:nTrailingZeros
        r(k) = 0;
    end
    eiga = eig(a);
    for k = 1:companDim
        r(eml_index_plus(k,nTrailingZeros)) = eiga(k);
    end
    nRoots = eml_index_plus(nTrailingZeros,companDim);
    assert(nRoots <= nc); %<HINT>
    r = r(1:nRoots);
end
