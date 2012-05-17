function yi = interp1(varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1) The only supported interpolation methods are 'linear' and 'nearest'.
%   2) Evenly spaced X indices will not be handled separately.
%   3) X must be strictly monotonically increasing or strictly monotonically
%      decreasing; indices will not be reordered.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2,'Not enough input arguments');
% Determine meanings of supplied and implicit parameters.
if nargin == 2
    % yi = interp1(y,xi);
    % method = 'linear'
    % exval = NaN
    % x not supplied.
    yi = interp1_work('linear',eml_guarded_nan,varargin{1},varargin{2});
elseif nargin == 3
    if ischar(varargin{3})
        % yi = interp1(y,xi,method)
        % exval = NaN
        % x not supplied.
        yi = interp1_work(varargin{3},eml_guarded_nan,varargin{1},varargin{2});
    else
        % yi = interp1(x,y,xi)
        % method = 'linear'
        % exval = NaN
        yi = interp1_work('linear',eml_guarded_nan,varargin{2},varargin{3},varargin{1});
    end
elseif nargin == 4
    if ischar(varargin{3})
        % yi = interp1(y,xi,method,exval_or_extrap)
        yi = interp1_work(varargin{3},varargin{4},varargin{1},varargin{2});
    else
        % yi = interp1(x,y,xi,method)
        % exval = NaN
        yi = interp1_work(varargin{4},eml_guarded_nan,varargin{2},varargin{3},varargin{1});
    end
else
    % yi = interp1(x,y,xi,method,exval_or_extrap)
    yi = interp1_work(varargin{4},varargin{5},varargin{2},varargin{3},varargin{1});
end

%--------------------------------------------------------------------------

function yi = interp1_work(method,exin,y,xi,x)
eml_assert(isa(y,'float'),'The table Y must contain only numbers');
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
xNotSupplied = nargin < 5;
if xNotSupplied
    yiZERO = eml_scalar_eg(y,xi);
else
    yiZERO = eml_scalar_eg(x,y,xi);
    eml_assert(isa(x,'float') && isreal(x), ...
        'The data abscissae should be real.');
    eml_lib_assert(isvector(x), ...
        'MATLAB:interp1:Xvector', ...
        'Argument X should be a vector.');
end
if ischar(exin)
    eml_assert(strcmp(exin,'extrap'),'Invalid extrapolation method.');
    extrapval = yiZERO + eml_guarded_nan;
    extrapbymethod = true;
else
    extrapval = yiZERO + exin;
    extrapbymethod = false;
end
eml_assert(isa(xi,'float') && isreal(xi), ...
    'The indices XI must contain only real numbers');
% Determine output class.
if eml_is_const(isvector(y)) && isvector(y) && ...
        eml_is_const(size(y,1)) && size(y,1) == 1
    yIsRowVector = true;
    nyrows = cast(size(y,2),eml_index_class);
    nycols = ONE;
    if xNotSupplied
        nx = nyrows;
    else
        nx = cast(eml_numel(x),eml_index_class);
        eml_lib_assert(nx == nyrows, ...
            'MATLAB:interp1:YInvalidNumRows', ...
            'X and Y must be of the same length.')
    end
    outsize = size(xi);
else
    eml_lib_assert(isscalar(y) || ~isvector(y) || size(y,1) ~= 1, ...
        'EmbeddedMATLAB:interp1:vsizeMatrixBecameRowVec', ...
        'A variable-size input matrix or N-D array must not become a row vector at runtime.');
    yIsRowVector = false;
    nyrows = cast(size(y,1),eml_index_class);
    nycols = eml_size_prod(y,TWO);
    if xNotSupplied
        nx = nyrows;
    else
        nx = cast(eml_numel(x),eml_index_class);
        eml_lib_assert(nx == nyrows, ...
            'MATLAB:interp1:YInvalidNumRows', ...
            'Y must have length(X) rows.');
    end
    if eml_is_const(isvector(y)) && isvector(y)
        outsize = size(xi);
    else
        ysize = size(y);
        if eml_is_const(isvector(xi)) && isvector(xi)
            outsize = [eml_numel(xi),ysize(2:end)];
        else
            eml_lib_assert(~isvector(xi), ...
                'EmbeddedMATLAB:interp1:arrayXItoVector', ...
                'Variable-size XI must always be a vector or never be a vector.');
            outsize = [size(xi),ysize(2:end)];
        end
    end
end
eml_lib_assert(nx > 1, ...
    'MATLAB:interp1:NotEnoughPts', ...
    'There should be at least two data points.');
yi = eml_expand(extrapval,outsize);
if isempty(xi)
    return
end
if xNotSupplied
    % X is implicitly 1:nx
    xlo = ones(class(xi));
    xhi = cast(nx,class(xi));
else
    for k = ONE:nx
        if isnan(x(k))
            eml_error('MATLAB:interp1:NaNinX','NaN is not an appropriate value for X.');
            return
        end
    end
    % Ensure that x is strictly monotonically increasing.
    if x(2) < x(1)
        % Non-increasing sequence.  Reverse it.
        x = x(end:-1:1);
        if yIsRowVector
            y = fliplr(y);
        else
            y = flipdim(y,1);
        end
    end
    for k = TWO:nx
        if x(k) <= x(k-1)
            eml_error('EmbeddedMATLAB:interp1:nonMonotonicX', ...
                'The data abscissae should be distinct and strictly monotonic.');
        end
    end
    xlo = x(1);
    xhi = x(end);
end
% main algorithm
nxi = cast(eml_numel(xi),eml_index_class);
nxm1 = eml_index_minus(nx,1);
switch(method)
    case {'nearest','*nearest'}
        for k = ONE:nxi
            iy0 = ZERO;
            if xi(k) > xhi
                if extrapbymethod
                    iy0 = nyrows;
                end
            elseif xi(k) < xlo
                if extrapbymethod
                    iy0 = ONE;
                end
            else
                if xNotSupplied
                    xn = min(floor(xi(k)),cast(nxm1,class(xi)));
                    xnp1 = xn + 1;
                    n = cast(xn,eml_index_class);
                    np1 = eml_index_plus(n,1);
                else
                    n = eml_bsearch(x,xi(k));
                    np1 = eml_index_plus(n,1);
                    xn = x(n);
                    xnp1 = x(np1);
                end
                if xi(k) >= eml_rdivide(xnp1+xn,2)
                    iy0 = np1;
                else
                    iy0 = n;
                end
            end
            if iy0 > ZERO
                iyi = k;
                iy = iy0;
                for j = ONE:nycols
                    yi(iyi) = y(iy);
                    iyi = eml_index_plus(iyi,nxi);
                    iy = eml_index_plus(iy,nyrows);
                end
            end
        end
    case {'linear','*linear'}
        nxm1 = eml_index_minus(nx,1);
        % Note:  r is always assigned in the loop because nxi >= 1.
        if xNotSupplied
            r = eml.nullcopy(eml_scalar_eg(xi));
        else
            r = eml.nullcopy(eml_scalar_eg(xi,x));
        end
        for k = ONE:nxi
            n = ZERO;
            if xi(k) > xhi
                if extrapbymethod
                    % extrapolate past the top
                    n = nxm1;
                    if xNotSupplied
                        r = xi(k) - (xhi - 1);
                    else
                        r = eml_rdivide(xi(k)-x(nxm1),x(nx)-x(nxm1));
                    end
                end
            elseif xi(k) < xlo
                if extrapbymethod
                    % extrapolate below the bottom
                    n = ONE;
                    if xNotSupplied
                        r = xi(k) - 1;
                    else
                        r = eml_rdivide(xi(k)-x(ONE),x(TWO)-x(ONE));
                    end
                end
            else
                if xNotSupplied
                    xn = min(floor(xi(k)),cast(nxm1,class(xi)));
                    n = cast(xn,eml_index_class);
                    r = xi(k) - xn;
                else
                    n = eml_bsearch(x,xi(k));
                    xn = x(n);
                    r = eml_rdivide(xi(k)-xn,x(eml_index_plus(n,1))-xn);
                end
            end
            if n > ZERO
                iyi = k;
                iy = n;
                for j = ONE:nycols
                    yi(iyi) = y(iy) + r*(y(eml_index_plus(iy,1)) - y(iy));
                    iyi = eml_index_plus(iyi,nxi);
                    iy = eml_index_plus(iy,nyrows);
                end
            end
        end
    otherwise
        eml_assert(false,'Unsupported method. Supported methods are ''linear'' and ''nearest''.');
end

%--------------------------------------------------------------------------
