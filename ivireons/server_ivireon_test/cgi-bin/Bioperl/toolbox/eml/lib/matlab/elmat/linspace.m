function y = linspace(d1,d2,n)
%Embedded MATLAB Library Function

%   Limitations:
%     If supplied, the number of points N must be positive, real, and 
%     integer valued.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if nargin < 3
    n = 100;
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
    'EmbeddedMATLAB:linspace:invalidN', ...
    'The number of points N must be a positive integer and real.'); 
y = eml.nullcopy(eml_expand(eml_scalar_eg(d1,d2),[1,n]));
y(n) = d2;
if n >= 2
    ks = double(0:n-2);
    y(1:n-1) = d1 + ks*eml_div(d2-d1,double(n-1));
end

