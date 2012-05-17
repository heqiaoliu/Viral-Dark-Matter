function P = pascal(n,k,classname)
%Embedded MATLAB Library Function

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin < 2
    k = 0;
end
if nargin < 3
    classname = 'double';
else
    eml_assert(eml_is_float_class(classname), ...
        'Third input must be ''double'' or ''single''.');
end
eml_prefer_const(n,k);
eml_assert(isa(n,'numeric'), ...
    ['Function ''pascal'' is not defined for values of N of class ''' class(n) '''.']);
eml_assert(isscalar(n),'First argument to ''pascal'' must be a scalar.');
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'First argument to ''pascal'' must be a constant, non-negative integer.');
eml_lib_assert(n == floor(n) && n >= 0, ...
    'EmbeddedMATLAB:pascal:nMustBeNonNegativeInteger', ...
    'First argument to ''pascal'' must be a non-negative integer.');
eml_lib_assert(isa(k,'numeric') && isscalar(k) && (k == 0 || k == 1 || k == 2), ...
    'MATLAB:pascal:InvalidArg2', ...
    'Second argument must be 0, 1, or 2.');
if n < 2
    P = ones(n,classname);
    return
end
P = zeros(n,classname);
P(:,1) = 1;
plusminus1 = cast(-1,classname);
for j = 2:n
    P(j,j) = plusminus1;
    plusminus1 = -plusminus1;
end
% Generate the Pascal Cholesky factor (up to signs).
if n > 2
    for j = 2:n-1
        for i = j+1:n
            P(i,j) = P(i-1,j) - P(i-1,j-1);
        end
    end
end
if k == 0
    P = P*P';
elseif k == 2
    P = rot90(P,3);
    if rem(n,2) == 0
        P = -P;
    end
end
