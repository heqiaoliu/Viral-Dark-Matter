function [p,S,mu] = polyfit(x,y,n)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_must_not_inline; % For clarity in the generated code.
eml_assert(nargin == 3, 'Not enough input arguments.');
eml_prefer_const(n);
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'N must be a constant.')
eml_assert(isa(n,'numeric') && isreal(n) && isscalar(n), ...
    'N must be scalar, numeric, and real.');
eml_assert(eml_is_const(isvector(x) && isvector(y)), ...
    ['X and Y must be vectors with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(x) && isvector(y), ...
    'POLYFIT data input must be vectors.');
eml_lib_assert(size(x,1) == size(y,1) && size(x,2) == size(y,2), ...
    'MATLAB:polyfit:XYSizeMismatch', ...
    'X and Y vectors must be the same size.');
if nargout > 2
    mu = [mean(x); std(x)];
    x = eml_div(x-mu(1),mu(2));
end
V = eml_vander(x,n);
if nargout > 1
    [p1,rr,R] = eml_qrsolve(V,y(:),true);
else
    [p1,rr] = eml_qrsolve(V,y(:),true);
end
if n >= eml_numel(x)
   eml_warning('MATLAB:polyfit:PolyNotUnique', ...
       'Polynomial is not unique; degree >= number of data points.')
elseif rr <= n
    if nargout > 2
        eml_warning('MATLAB:polyfit:RepeatedPoints', ...
                ['Polynomial is badly conditioned. Add points with distinct X\n' ...
                 '         values or reduce the degree of the polynomial.']);
    else
        eml_warning('MATLAB:polyfit:RepeatedPointsOrRescale', ...
                ['Polynomial is badly conditioned. Add points with distinct X\n' ...
                 '         values, reduce the degree of the polynomial, or try centering\n' ...
                 '         and scaling as described in HELP POLYFIT.']);
    end
end
if nargout > 1
    r = y(:) - V*p1;
    % S is a structure containing three elements: the triangular factor from a
    % QR decomposition of the Vandermonde matrix, the degrees of freedom and
    % the norm of the residuals.
    S.R = R;
    S.df = max(0,length(y) - (n+1));
    S.normr = norm(r);
end
p = p1.'; % Polynomial coefficients are row vectors by convention.
