function p = eml_size_ispow2(n)
%Embedded MATLAB Private Function

%   Returns true if the size scalar n is a power of 2, false otherwise.

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 1, 'Not enough input arguments.');
    eml_assert(isscalar(n), 'Input must be a scalar.');
    eml_assert(isa(n,'numeric'), 'Input must be numeric.');
    eml_assert(isreal(n), 'Input must be real.');
end
eml_prefer_const(n);
if n <= 0
    p = false;
elseif isinteger(n)
    % Use formula p = ~(n&(n-1)).
    ucls = eml_unsigned_class(class(n));
    u = cast(n,ucls);
    p = (eml_bitand(u,eml_minus(u,1,ucls,'wrap')) == 0);
elseif n == floor(n)
    if eml_ambiguous_types
        r = eml_rdivide(eml_log(n),eml_log(2));
        p = (r == floor(r));
    else
        u = cast(n,eml_unsigned_class(eml_index_class));
        p = eml_size_ispow2(u);
    end
else
    p = false;
end
