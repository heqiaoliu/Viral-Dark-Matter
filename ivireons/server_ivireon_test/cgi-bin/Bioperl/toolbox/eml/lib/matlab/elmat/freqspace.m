function [f1,f2] = freqspace(n,flag)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin>0, 'Not enough input arguments.');
eml_assert(eml_is_const(size(n)), 'N must have fixed-size.');
eml_assert(isvector(n) && (eml_numel(n) == 1 || eml_numel(n) == 2), ...
    'N must be a scalar or a vector with 2 elements.');
eml_assert(nargout > 1 || isscalar(n), ...
    'For single output, input N must be scalar.');
eml_assert(eml_is_const(n) || eml_option('VariableSizing'), ...
    'First input must be a constant.');
eml_assert(isreal(n), 'N must be real.');
eml_assert(isa(n,'float'), ...
    ['Function ''freqspace'' is not defined for values of class ''' ...
    class(n) '''.']);
eml_assert(nargin < 2 || ischar(flag), ...
    'Second argument must be a string.');
if nargout > 1
    if isscalar(n)
        r = floor(eml_div(n,2));
        s = eml_div(2,n);
        if nargin > 1
            a = ((0:n-1) - r)*s;
            [f1,f2] = meshgrid(a);
        else
            f1 = ((0:n-1) - r)*s;
            f2 = f1;
        end
    else
        r1 = floor(eml_div(n(1),2));
        r2 = floor(eml_div(n(2),2));
        s1 = eml_div(2,n(1));
        s2 = eml_div(2,n(2));
        if nargin > 1
            a = ((0:n(2)-1) - r2)*s2;
            b = ((0:n(1)-1) - r1)*s1;
            [f1,f2] = meshgrid(a,b);
        else
            f1 = ((0:n(2)-1) - r2)*s2;
            f2 = ((0:n(1)-1) - r1)*s1;
        end
    end
elseif nargin > 1
    if n < 1
        f1 = zeros(1,0,class(n)); 
    else
        f1 = colon(0,eml_div(2,n),eml_div(2*(n-1),n));
    end
else % nargin == 1 && nargout == 1
    if n < 0          % [-Inf, 0)
        f1 = zeros(1,0,class(n));
    elseif n == 0     % [0, 0]    
        f1 = eml_guarded_nan(class(n));
    elseif n < 2      % (0, 2)
        f1 = zeros(class(n));
    else              % (2, Inf]
        f1 = colon(0,eml_div(2,n),1);
    end
end