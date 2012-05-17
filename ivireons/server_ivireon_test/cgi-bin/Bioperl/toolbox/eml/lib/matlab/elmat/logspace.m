function y = logspace(d1,d2,n)
%Embedded MATLAB Library Function

%   Limitations:  Does not support special case behavior for d2 = pi.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if nargin < 3
    n = 50;
end
eml_prefer_const(n);
eml_assert(nargin > 1, 'Not enough input arguments');
eml_assert(isa(d1,'float') && isscalar(d1), ...
    'Input d1 must be a scalar floating-point value.');
eml_assert(isa(d2,'float') && isscalar(d2), ...
    'Input d2 must be a scalar floating-point value.');
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'The number of points N must be a constant.');
eml_lib_assert(isa(n,'numeric') && isreal(n) && isscalar(n) && n >= 1 && ...
    eml_scalar_floor(n) == n, ...
    'EmbeddedMATLAB:logspace:invalidN', ...
    'The number of points N must be a positive integer and real.'); 
if (abs(d2 - cast(pi,class(d2))) < 4*eps(class(d2)))
    eml_warning('EmbeddedMATLAB:piSpecialSupported', ...
        'Special case for pi is not supported. Use logspace(a,log10(pi),n) if desired.');
end
y = 10 .^ linspace(d1,d2,n);
