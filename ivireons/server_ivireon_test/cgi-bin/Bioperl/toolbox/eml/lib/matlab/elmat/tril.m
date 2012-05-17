function x = tril(x,k)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_lib_assert(ndims(x) == 2, ...
    'MATLAB:tril:firstInputMustBe2D', ...
    'First input must be 2D.');
% Constants.
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
ONE = ones(eml_index_class);
% Assimilate K argument.
if nargin == 1
    k = 0;
else
    eml_prefer_const(k);
    eml_lib_assert(isa(k,'numeric') && isscalar(k) && ...
        isreal(k) && floor(k) == k, ...
        'MATLAB:tril:kthDiagInputNotInteger', ...
        'K-th diagonal input must be an integer scalar.');
end
% Calculate limits.
if isempty(x) || k + 1 >= n
    % Trivial case.  No change to x.
    return
elseif k < 0
    if -k > m % Guarantee 1 <= iend <= m.
        iend = m;
    else
        iend = cast(-k,eml_index_class);
    end
    jstart = ONE;
else
    iend = ONE;
    jstart = cast(k+2,eml_index_class); % 2 <= jstart <= n is guaranteed.
end
% Zero matrix elements.
for j = jstart:n
    for i = ONE:iend
        x(i,j) = 0;
    end
    if iend < m
        iend = eml_index_plus(iend,ONE);
    end
end
