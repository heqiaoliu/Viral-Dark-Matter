function xy = cov(x,y,flag)
%Embedded MATLAB Library Function

%   Notes:
%   1. Output on the diagonal is always real (as it should be).
%      Example:  cov([1,2i;nan,4;7,2])

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''cov'' is not defined for values of class ''' ...
    class(x) '''.']);
% Check for cov(x,flag) or cov(x,y,flag)
if nargin == 3
    eml_prefer_const(flag);
    eml_assert(eml_is_const(size(flag)), ...
        'Third input must be a fixed-size scalar.');
    eml_lib_assert(isscalar(flag) && ...
        (flag == 0 || flag == 1), ...
        'MATLAB:cov:notScalarFlag', ...
        'Third input must be 0 or 1.');
    unbiasedp = (flag == 0);
    nin = 2;
elseif nargin == 2
    eml_lib_assert(~isscalar(x) || ~isscalar(y) || y(1) == 0 || y(1) == 1, ...
        'EmbeddedMATLAB:cov:thirdInputRequired', ...
        ['Third input required for covariance of scalar x and scalar y. ', ...
        'Use ''cov(x,y,0)''.']);
    if eml_is_const(size(y)) && isscalar(y)
        unbiasedp = (y == 0);
        nin = 1;
    else
        unbiasedp = true;
        nin = 2;
    end
else
    unbiasedp = true;
    nin = 1;
end
if nin == 2
    eml_assert(isa(y,'float'), ...
        ['Function ''cov'' is not defined for values of class ''' ...
        class(y) '''.']);
    eml_lib_assert(eml_numel(x) == eml_numel(y), ...
        'MATLAB:cov:XYlengthMismatch', ...
        'The number of elements in x and y must match.');
    xy = eml_cov([x(:),y(:)],unbiasedp);
elseif eml_is_const(isvector(x)) && isvector(x)
    xy = eml_cov(x(:),unbiasedp);
else
    eml_lib_assert(isscalar(x) || ~isvector(x), ...
        'EmbeddedMATLAB:cov:vsizeMatrixIsVector', ...
        ['A variably-sized matrix input to COV must not become a ', ...
        'vector input at runtime. Use a variable-length vector instead.']);
    xy = eml_cov(x,unbiasedp);
end

%--------------------------------------------------------------------------

function xy = eml_cov(x,unbiasedp)
eml_lib_assert(ndims(x)==2, ...
    'MATLAB:cov:inputMustBe2D', ...
    'Input must be 2-D.');
fm = cast(size(x,1),class(x));
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
xzero = eml_scalar_eg(x);
if eml_is_const(size(x)) && m == 0 && n == 0
    xy = eml_guarded_nan + xzero;
    return
end
xy = eml_expand(xzero,[n,n]);
if m == 0 && n > 0
    xy(:) = eml_guarded_nan;
elseif m == 1
    % One observation For single data, unbiased estimate of the covariance
    % matrix is not defined. Return the second moment matrix of the
    % observations about their mean.
else
    % x = x - repmat(sum(x,1)/m,m,1);  % Remove mean
    for j = 1:n
        s = xzero;
        for i = 1:m
            s = s + x(i,j);
        end
        s = s / fm;
        for i = 1:m
            x(i,j) = x(i,j) - s;
        end
    end
    if unbiasedp
        fm = fm - 1;
    end
    % xy = (x' * x) / m;
    % Could use xHERK here.
    for j = 1:n
        % Calculate diagonal element.
        d = real(xzero);
        for k = 1:m
            d = d + real(x(k,j))*real(x(k,j)) + imag(x(k,j))*imag(x(k,j));
        end
        xy(j,j) = d / fm;
        for i = j+1:n
            % xy(i,j) = dot(x(:,i),x(:,j))/fm;
            s = xzero;
            for k = 1:m
                s = s + eml_conjtimes(x(k,i),x(k,j));
            end
            xy(i,j) = s / fm;
            xy(j,i) = conj(xy(i,j));
        end
    end
end

%--------------------------------------------------------------------------
