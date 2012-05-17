function y = var(x,w,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float') || ischar(x), ...
    ['Function ''var'' is not defined for values of class ''' class(x) '''.']);
% Set unsupplied arguments to default values.
if nargin < 3
    if eml_is_const(size(x)) && isequal(x,[]) % Special case.
        y = eml_guarded_nan(class(x));
        return
    end
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:var:specialEmpty', ...
        'VAR with one variable-size matrix input of [] is not supported.');
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:var:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
    
    if nargin < 2
        w = cast(0,class(x));
    end
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
eml_assert(isa(w,'float') || ischar(w), ...
    ['Function ''var'' is not defined for values of class ''' class(w) '''.']);
% Recursive calls to regularize the input.
if eml_is_const(size(w)) && isempty(w)
    % Replace w with zero.
    y = var(x,zeros(class(x)),dim);
    return
elseif ischar(x)
    if isscalar(w) || ischar(w)
        y = var(double(x),double(w),dim);
    else
        y = var(cast(x,class(w)),w,dim);
    end
    return
elseif ischar(w)
    y = var(x,cast(w,class(x)),dim);
    return
end
% X and W are singles or doubles from this point onward.
n = size(x,dim);
if eml_is_const(size(w)) && isscalar(w)
    % Unweighted variance
    % W is a flag, does not affect output class.
    yzero = eml_scalar_eg(x);
    if ~(w == 0 || w == 1)
        eml_error('MATLAB:var:invalidWgts', ...
            'W must be a vector of nonnegative weights, or a scalar 0 or 1.');
        d = zeros(class(x));
    elseif w == 0 && n > 1
        % The unbiased estimator: divide by (n-1).  Can't do this
        % when n == 0 or 1.
        d = cast(n-1,class(x));
    else
        % The biased estimator: divide by n.
        d = cast(n,class(x)); % n==0 => return NaNs, n==1 => return zeros
    end
else
    eml_lib_assert(eml_numel(w) == n, ...
        'MATLAB:var:invalidSizeWgts', ...
        'The length of W must be compatible with X.');
    % W is a weight vector, influences output class.
    yzero = eml_scalar_eg(real(x),w);
    sumw = yzero;
    for k = 1:n
        if w(k) < 0
            eml_error('MATLAB:var:invalidWgts', ...
                'W must be a vector of nonnegative weights, or a scalar 0 or 1.');
        end
        sumw = sumw + w(k);
    end
    % Normalize W.
    d = eml_div(w,sumw);
end
if eml_is_const(n) && n == 1 % Covers dim > ndims(x) case.
    % Generate NaNs with nonfinite inputs, otherwise zeros.
    y = yzero.*abs(x);
    return
end
sz = size(x);
sz(dim) = 1;
y = eml.nullcopy(eml_expand(yzero,sz));
% Compute variance.
vstride = eml_matrix_vstride(x,dim);
vspread = eml_index_times(eml_index_minus(n,1),vstride);
npages = eml_matrix_npages(x,dim);
ix = zeros(eml_index_class);
iy = zeros(eml_index_class);
for i = 1:npages
    for j = 1:vstride
        ix = eml_index_plus(ix,1);
        iy = eml_index_plus(iy,1);
        y(iy) = vector_variance(x,d,ix,vstride,n);
    end
    ix = eml_index_plus(ix,vspread);
end

%--------------------------------------------------------------------------

function y = absdiff_squared(x,xbar)
% abs(x - xbar)^2
eml_must_inline;
if isreal(x) && isreal(xbar)
    r = x - xbar;
    y = r*r;
else
    c = x - xbar;
    cre = real(c);
    cim = imag(c);
    y = cre*cre + cim*cim;
end

%--------------------------------------------------------------------------

function y = vector_variance(x,w,ixstart,stride,n)
% Variance of the vector x(ixstart:stride:ixstart+(n-1)*stride)
% using denominator w if w is a scalar or weights if w is a vector.
% If isempty(x), the result is eml_guarded_nan(class(x));
if isempty(x)
    y = eml_guarded_nan(class(x)) + eml_scalar_eg(real(x),w);
elseif eml_is_const(size(w)) && isscalar(w)
    ix = ixstart;
    xbar = x(ix);
    for k = 2:n
        ix = eml_index_plus(ix,stride);
        xbar = xbar + x(ix);
    end
    xbar = eml_div(xbar,n);
    ix = ixstart;
    y = absdiff_squared(x(ix),xbar);
    for k = 2:n
        ix = eml_index_plus(ix,stride);
        y = y + absdiff_squared(x(ix),xbar);
    end
    y = eml_div(y,w);
else
    ix = ixstart;
    xbar = w(1)*x(ix);
    for k = 2:n
        ix = eml_index_plus(ix,stride);
        xbar = xbar + w(k)*x(ix);
    end
    ix = ixstart;
    y = w(1)*absdiff_squared(x(ix),xbar);
    for k = 2:n
        ix = eml_index_plus(ix,stride);
        y = y + w(k)*absdiff_squared(x(ix),xbar);
    end
end

%--------------------------------------------------------------------------
