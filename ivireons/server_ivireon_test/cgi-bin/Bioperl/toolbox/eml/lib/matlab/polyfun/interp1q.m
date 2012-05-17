function yi = interp1q(x,y,xi)
%Embedded MATLAB Library Function

%   Limitations:
%   1) X must be strictly monotonically increasing or strictly monotonically
%      decreasing; indices will not be reordered.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 3,'Input argument XI is undefined.');
eml_assert(isa(x,'float') && isreal(x),'The data abscissae should be real.');
eml_assert(isa(y,'float'),'The table Y must contain only numbers.');
eml_assert(isa(xi,'float') && isreal(xi),'The indices XI must contain only real numbers.');
if eml_is_const(size(x)) && eml_is_const(size(y)) && eml_is_const(size(xi))
    % The purpose of interp1q is reduced overhead, so we only do these
    % checks when they can be resolved at compile time.
    eml_assert(size(x,1)==eml_numel(x),'Input argument X must be a column vector.');
    eml_assert(size(xi,1)==eml_numel(xi),'Input argument XI must be a column vector.');
    eml_assert(size(x,1)==size(y,1),'Y must have length(X) rows.');
end
% Determine output class.
if isa(x,'single') || isa(y,'single') || isa(xi,'single')
    outcls = 'single';
else
    outcls = 'double';
end
% Preallocate storage for output and initialize.
if isreal(y)
    yi = eml_guarded_nan + zeros(eml_numel(xi),size(y,2),outcls);
else
    yi = complex(eml_guarded_nan + zeros(eml_numel(xi),size(y,2),outcls));
end
for k = 1:eml_numel(xi)
    t = xi(k);
    if t >= x(1) && t <= x(end)
        n = eml_bsearch(x,xi(k));
        np1 = eml_index_plus(n,1);
        r = eml_rdivide(t-x(n),x(np1)-x(n));
        yi(k,:) = y(n,:) + r*(y(np1,:) - y(n,:));
    end
end
