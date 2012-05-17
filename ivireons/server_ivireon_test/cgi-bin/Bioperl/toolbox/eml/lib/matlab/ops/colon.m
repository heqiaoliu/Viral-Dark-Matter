function y = colon(a,d,b)
%Embedded MATLAB Library Function

%   NOTES:
%   1. Does not accept complex inputs.
%   2. Does not accept logical D.
%   3. Does not accept vector inputs.
%   4. Inputs must be constants.
%   5. Single precision results are filled using single-precision
%   arithmetic.

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_prefer_const(a);
eml_prefer_const(d);
if nargin < 3
    y = colon(a,1,d);
    return
end
eml_prefer_const(b);
if ~( ...
        eml_is_const(isscalar(a)) && isscalar(a) && ...
        eml_is_const(isscalar(d)) && isscalar(d) && ...
        eml_is_const(isscalar(b)) && isscalar(b))
    eml_lib_assert(isscalar(a) && isscalar(d) && isscalar(b), ...
        'EmbeddedMATLAB:colon:operandsMustBeScalars', ...
        'Colon operands must be real scalars.');
    y = colon(a(1),d(1),b(1));
    return
end
eml_assert(isa(a,'numeric') || ischar(a), ...
    ['Function ''colon'' is not defined for values of class ''' class(a) '''.']);
eml_assert(isa(d,'numeric') || ischar(d), ...
    ['Function ''colon'' is not defined for values of class ''' class(d) '''.']);
eml_assert(isa(b,'numeric') || ischar(b), ...
    ['Function ''colon'' is not defined for values of class ''' class(b) '''.']);
eml_assert(eml_option('VariableSizing') || ...
    (eml_is_const(a) && eml_is_const(d) && eml_is_const(b)), ...
    'Operands must be constants.');
eml_assert(isreal(a) && isreal(d) && isreal(b), ...
    'Colon operands must be real scalars.');
isda = isa(a,'double');
isdb = isa(b,'double');
isdd = isa(d,'double');
eml_assert( ...
    (isda || isdd || isa(a,class(d))) && ...
    (isda || isdb || isa(a,class(b))) && ...
    (isdd || isdb || isa(d,class(b))), ...
    'Colon operands must be all the same type, or mixed with real scalar doubles.');
if ischar(a) || ischar(d) || ischar(b)
    eml_assert(ischar(a) && ischar(b), ...
        'For colon operator with char operands, first and last operands must be char.');
    eml_assert(ischar(d) || isa(d,'double'), ...
        'For colon operator with char operands, second operand must be char or real scalar double.');
    eml_lib_assert( ...
        (~isda || floor(a) == a) && ...
        (~isdd || floor(d) == d) && ...
        (~isdb || floor(b) == b), ...
        'MATLAB:colon:scalarDoubleMustBeIntegerValued', ...
        'Double operands interacting with char operands must have integer values.');
    y = char(eml_integer_colon(int8(a),double(d),int8(b)));
elseif isinteger(a) || isinteger(d) || isinteger(b)
    eml_lib_assert( ...
        (~isda || floor(a) == a) && ...
        (~isdd || floor(d) == d) && ...
        (~isdb || floor(b) == b), ...
        'MATLAB:colon:scalarDoubleMustBeIntegerValued', ...
        'Double operands interacting with integer operands must have integer values.');
    y = eml_integer_colon(a,d,b);
elseif is_flint_colon(a,d,b)
    y = eml_integer_colon(a,d,b);
else
    y = eml_float_colon(a,d,b);
end

%--------------------------------------------------------------------------

function p = is_flint_colon(a,d,b)
% Returns true if the colon output can be computed using flints.
eml_prefer_const(a);
eml_prefer_const(d);
eml_prefer_const(b);
p = isfinite(a) && isfinite(d) && isfinite(b) && ...
    floor(a) == a && floor(d) == d && ...
    eps(maxabs(a,b)) <= 1;

%--------------------------------------------------------------------------

function checkrange(a,d,b)
% Assert that A and B are in range for class(A:D:B).
eml_prefer_const(a);
eml_prefer_const(d);
eml_prefer_const(b);
yzero = zerosum(a,d,b);
outcls = class(yzero);
if isa(yzero,'float')
    ubnd = realmax(outcls);
    lbnd = -ubnd;
else
    lbnd = intmin(outcls);
    ubnd = intmax(outcls);
end
eml_lib_assert( ...
    (isa(a,outcls) || (a <= ubnd && a >= lbnd)) && ...
    (isa(b,outcls) || (b <= ubnd && b >= lbnd)), ...
    'MATLAB:colon:OutOfRange', ...
    'Colon operands must be in range of the data type.');

%--------------------------------------------------------------------------

function n = unrounded_npoints(a,d,b)
% Computes n = 1 + (b - a)/d.  If any of the inputs are nan, the result is
% -1.  Asserts that n < realmax.  Like MATLAB, we don't handle cases like
% -realmax:realmax:realmax properly, but this function would be the place
% to add logic to avoid overflow of (b-a)/d when possible.
eml_prefer_const(a);
eml_prefer_const(d);
eml_prefer_const(b);
if isnan(a) || isnan(d) || isnan(b)
    n = -1;
elseif (d == 0) || (a < b && d < 0) || (b < a && d > 0)
    n = 0;
elseif isinf(a) || isinf(d) || isinf(b)
    eml_lib_assert(isinf(d) || a == b, 'MATLAB:pmaxsize', ...
        'Maximum variable size allowed by the program is exceeded.');
    n = -1;
else
    n = 1 + eml_rdivide(b-a,d);
end
eml_lib_assert(n < realmax, 'MATLAB:pmaxsize', ...
    'Maximum variable size allowed by the program is exceeded.');

%--------------------------------------------------------------------------

function y = eml_integer_colon(a,d,b)
% Compute Y = A0:D0:B0 for the integer and flint cases.  Assumes that A0,
% D0, and B0 are integer valued, either from an integer class or floats.
eml_prefer_const(a);
eml_prefer_const(d);
eml_prefer_const(b);
checkrange(a,d,b);
if (d == 0) || (a < b && d < 0) || (b < a && d > 0)
    y = zeros(1,0,class(zerosum(a,d,b)));
else
    eml_lib_assert(1+floor((double(b)-double(a))/double(d)) < double(intmax()), ...
        'MATLAB:pmaxsize', ...
        'Maximum variable size allowed by the program is exceeded.');
    y = eml_colonobj(a,d,b).';
end

%--------------------------------------------------------------------------

function [n,a,b] = double_colon_parms(a0,d0,b0)
% Returns the number of elements N in the output vector to be constructed
% and double precision colon parameters A, D, and B. The output value
% of B is adjusted to be consistent with A and D to near working
% precision.
eml_prefer_const(a0);
eml_prefer_const(d0);
eml_prefer_const(b0);
a = double(a0);
d = double(d0);
b = double(b0);
n = unrounded_npoints(a,d,b);
if n < 0
    a = eml_guarded_nan;
    n = 1;
elseif n > 0
    n = floor(n - 0.5);
    apnd = a + n*d;
    if d > 0
        e = apnd - b;
    else
        e = b - apnd;
    end
    if abs(e) < 2*double(eps(class(zerosum(a0,d0,b0))))*maxabs(a,b)
        n = n + 1;
    elseif e > 0 % overshot
        b = a + (n-1)*d;
    else % undershot
        n = n + 1;
        b = apnd;
    end
end

%--------------------------------------------------------------------------

function y = float_colon_fill(n,a,d,b)
% Returns Y filled with A:D:B, where B = A + (N-1)*D to near working
% precision.  The lower half of Y is computed as A + k*D, and the upper
% half of Y is computed as B - k*D.  For odd N, Y((N+1)/2) = (A + B)/2.
eml_prefer_const(n);
eml_prefer_const(a);
eml_prefer_const(d);
eml_prefer_const(b);
y = zeros(1,n,class(zerosum(a,d,b)));
if n == 0
elseif n == 1
    y(1) = a;
elseif n == 2
    y(1) = a;
    y(n) = b;
else
    y(1) = a;
    y(n) = b;
    nm1 = n - 1;
    nm1d2 = floor(eml_rdivide(nm1,2));
    if 2*nm1d2 == nm1 % N is odd.
        for k = 1:nm1d2-1
            kd = k*d;
            y(k+1) = a + kd;
            y(n-k) = b - kd;
        end
        y(nm1d2+1) = eml_rdivide(a+b,2);
    else % N is even.
        for k = 1:nm1d2
            kd = k*d;
            y(k+1) = a + kd;
            y(n-k) = b - kd;
        end
    end
end

%--------------------------------------------------------------------------

function y = eml_float_colon(a,d,b)
% Compute Y = A0:D0:B0 for a possibly non-integer stride D0.
% Size-determining computations, which we expect to constant-fold, are
% performed in double precision floating point, but unlike MATLAB, we use
% single precision for the arithmetic in the fill operation if A or D is
% single precision.
eml_prefer_const(a);
eml_prefer_const(d);
eml_prefer_const(b);
checkrange(a,d,b);
[n,a1,b1] = double_colon_parms(a,d,b);
% Update
a(1) = a1; b(1) = b1;
y = float_colon_fill(n,a,d,b);

%--------------------------------------------------------------------------

function c = maxabs(a,b)
% c = max(abs(a),abs(b)) without going through the machinery of MAX.
eml_prefer_const(a);
eml_prefer_const(b);
absa = abs(a);
absb = abs(b);
if abs(a) > abs(b)
    c = absa;
else
    c = absb;
end

%--------------------------------------------------------------------------

function zero = zerosum(a,d,b)
% Returns the scalar 0 of the combined class of the input arguments.
zero = cast(0,class(a)) + cast(0,class(d)) + cast(0,class(b));

%--------------------------------------------------------------------------
