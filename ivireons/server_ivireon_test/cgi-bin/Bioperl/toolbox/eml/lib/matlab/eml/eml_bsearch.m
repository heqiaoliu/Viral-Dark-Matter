function n = eml_bsearch(x,xi)
%Embedded MATLAB Private Function

%   Binary search for the largest index N such that X(N) <= XI, where N
%   ranges from 1 to numel(X)-1. N belongs to eml_index_class. No error
%   checking. It is assumed that X is sorted ascending. Generally it is
%   expected that X(1) <= XI < X(end).  The following edge case behavior is
%   guaranteed (but may or may not be useful):
%   1. XI < X(1) --> N = 1.
%   2. XI >= X(end) --> N = numel(X)-1.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
ucls = eml_unsigned_class(eml_index_class);
ONE = ones(ucls);
TWO = cast(2,ucls);
low_i = ONE;
low_ip1 = TWO;
high_i = cast(eml_numel(x),ucls);
% Use the simpler midpoint calculation if it is guaranteed not to overflow.
% Otherwise use the more complicated method that avoids overflow.
if eml_is_const(size(x)) && ...
        eml_const(eml_numel(x) <= eml_rshift(intmax(ucls),ONE))
    midfun = @mid_small;
else
    midfun = @mid_large;
end
while high_i > low_ip1
    mid_i = midfun(low_i,high_i);
    if xi >= x(mid_i)
        low_i = mid_i;
        low_ip1 = eml_plus(low_i,ONE,ucls,'spill');
    else
        high_i = mid_i;
    end
end
n = cast(low_i,eml_index_class);

%--------------------------------------------------------------------------

function mid_i = mid_large(low_i,high_i)
% Avoid overflow in computation of mid_i.  Computes mid_i by
% low_i/2 + high_i/2 and subsequently adding 1 to the result if
% low_i and high_i are both odd.  One way to test this is to make
% eml_index_class uint16 and pass in a table X,Y of size larger
% than 32768 elements to interp1(X,Y,XI) for some "large"
% values of XI (in the larger half of X).
eml_must_inline;
ucls = class(low_i);
ONE = ones(ucls);
mid_i = eml_plus(eml_rshift(low_i,ONE),eml_rshift(high_i,ONE),ucls,'spill');
if (eml_bitand(low_i,ONE) == ONE) && (eml_bitand(high_i,ONE) == ONE)
    mid_i = eml_plus(mid_i,ONE,ucls,'spill');
end

%--------------------------------------------------------------------------

function mid_i = mid_small(low_i,high_i)
% Compute mid_i in the usual way, (low_i + high_i)/2.
eml_must_inline;
ucls = class(low_i);
mid_i = eml_rshift(eml_plus(low_i,high_i,ucls,'spill'),ones(ucls));

%--------------------------------------------------------------------------
