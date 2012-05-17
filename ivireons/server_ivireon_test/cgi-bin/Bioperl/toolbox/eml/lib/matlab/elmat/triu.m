function x = triu(x,k)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_lib_assert(ndims(x) == 2, ...
    'MATLAB:triu:firstInputMustBe2D', ...
    'First input must be 2D.');
% Constants.
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
ONE = ones(eml_index_class);
if nargin == 1
    k = 0;
else
    eml_prefer_const(k);
    eml_lib_assert(isa(k,'numeric') && isscalar(k) && ...
        isreal(k) && floor(k) == k, ...
        'MATLAB:triu:kthDiagInputNotInteger', ...
        'K-th diagonal input must be an integer scalar.');
end
% Calculate limits.
if isempty(x) || 1 - k >= m
    % Trivial case.  No change to x.
    return
elseif k > 0
    istart = ONE;
    if k < n % Guarantee 1 <= jstart <= n.
        jstart = cast(k,eml_index_class);
    else
        jstart = n;
    end
else
    istart = cast(2-k,eml_index_class); %  2 <= istart <= m is guaranteed.
    jstart = ONE;
end
nrowsm1 = eml_index_minus(m,istart);
ncolsm1 = eml_index_minus(n,jstart);
if nrowsm1 < ncolsm1
    jend = eml_index_plus(jstart,nrowsm1);
else
    jend = eml_index_plus(jstart,ncolsm1);
end

% Zero matrix elements.
for j = ONE:jend
    for i = istart:m
        x(i,j) = 0;
    end
    if j >= jstart
        istart = eml_index_plus(istart,ONE);
    end
end
