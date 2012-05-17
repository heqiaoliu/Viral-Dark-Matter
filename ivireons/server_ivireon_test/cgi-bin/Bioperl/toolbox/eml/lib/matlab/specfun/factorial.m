function n = factorial(n)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(isa(n,'float') && isreal(n), ...
    'N must be a matrix of non-negative floating-point integers.');
for k = 1:eml_numel(n)
    n(k) = scalar_factorial(n(k));
end

%--------------------------------------------------------------------------

function n = scalar_factorial(n)
% Factorial of a scalar n.
% Build the lookup table.  This will be a constant array at runtime.
maxfinite = eml_const(factorial_inf_threshold(class(n)));
factorial_table = eml_const(build_factorial_table(maxfinite,class(n)));
if n < 0 || floor(n) ~= n || ~isfinite(n)
    eml_error('MATLAB:factorial:NNegativeInt', ...
        'N must be a matrix of non-negative integers.');
    n = eml_guarded_nan(class(n));
else
    % Casting n to eml_index_class combined with the following bounding 
    % logic helps the compiler to eliminate bounds checking on the table 
    % lookup to follow.
    nidx = cast(n,eml_index_class);
    if nidx > maxfinite
        n = eml_guarded_inf(class(n));
    elseif nidx < 1
        n = ones(class(n));
    else
        n = factorial_table(nidx);
    end
end

%--------------------------------------------------------------------------

function f = build_factorial_table(n,cls)
% Build a table of factorials, factorial(1:n), of the given class.
f = cast([1,cumprod(2:double(n))],cls);

%--------------------------------------------------------------------------

function n = factorial_inf_threshold(cls)
% Calculate the largest integer n such that factorial(n) is finite.
ONE = ones(cls);
n = ONE;
x = ONE;
xlast = zeros(cls);
while x > xlast
    n = n + ONE;
    xlast = x;
    x = x * n;
end
% Both x and xlast are inf (or saturated), so subract 2 from n.
n = n - 2;

%--------------------------------------------------------------------------
