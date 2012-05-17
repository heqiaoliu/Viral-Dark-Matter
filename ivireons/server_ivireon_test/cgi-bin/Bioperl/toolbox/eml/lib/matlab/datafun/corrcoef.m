function [r,p,rlo,rup] = corrcoef(x,varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1. Row-vector input is only supported when the first two inputs are
%      vectors and non-scalar.
%
%   Notes:
%   1. Output on the diagonal is always real (as it should be).
%      Example:  corrcoef([1,2i;nan,4;7,2])

%   Fallout from converting all row vectors to column vectors:
%   1. corrcoef(x,'rows','complete') where x is 3xn and 2 rows of x have
%      at least one NaN.  See also corrcoef([1,NaN;1,2],'rows','complete').
%   2. corrcoef(x,y) if x and y are scalars.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin > 1 && isa(varargin{1},'numeric')
    % Second argument is data.  Combine it with the first argument and
    % recurse.
    % Give a decent error message if the third argument is numeric instead
    % of recursing.
    eml_assert(nargin == 2 || ~isa(varargin{2},'numeric'), ...
        'Expected a parameter name.');
    % Convert two inputs to equivalent single input.
    eml_assert(eml_ndims(x) == 2 && eml_ndims(varargin{1}) == 2, ...
        'Inputs must be 2-D.');
    eml_lib_assert(eml_numel(x) == eml_numel(varargin{1}), ...
        'EmbeddedMATLAB:corrcoef:xyMismatch', ...
        'X and Y inputs must have the same number of elements.');
    if nargout < 2
        r = corrcoef([x(:),varargin{1}(:)],varargin{2:end});
    elseif nargout == 2
        [r,p] = corrcoef([x(:),varargin{1}(:)],varargin{2:end});
    elseif nargout == 3
        [r,p,rlo] = corrcoef([x(:),varargin{1}(:)],varargin{2:end});
    else
        [r,p,rlo,rup] = corrcoef([x(:),varargin{1}(:)],varargin{2:end});
    end
    return
end
eml_assert(eml_ndims(x) == 2, ... % 'MATLAB:corrcoef:InputDim', ...
    'Inputs must be 2-D.');
eml_lib_assert(size(x,1) ~= 1 || size(x,2) == 1, ...
    'EmbeddedMATLAB:corrcoef:unsupportedRowVector', ...
    ['Row-vector input is only supported when the ', ...
    'first two inputs are vectors and non-scalar.']);
nr = size(x,2);
if eml_ambiguous_types
    r = eml_expand(eml_scalar_eg(x),[nr,nr]);
    p = zeros(nr,class(x));
    rlo = zeros(nr,class(x));
    rup = zeros(nr,class(x));
    return
end
CALC_P = nargout >= 2;
CALC_CONF = nargout >= 3;
eml_assert(~CALC_P || isreal(x), ...
    'Cannot compute p-values for complex inputs.');
% Parse inputs.
parms = struct( ...
    'alpha',uint32(0), ...
    'rows',uint32(0));
poptions = struct( ...
    'CaseSensitivity',true, ...
    'PartialMatching',true, ...
    'StructExpand',false);
pstruct = eml_parse_parameter_inputs(parms,poptions,varargin{:});
alpha = eml_get_parameter_value(pstruct.alpha,0.05,varargin{:});
eml_lib_assert(~logical(pstruct.alpha) || ...
    (isa(alpha,'numeric') && isscalar(alpha) && alpha > 0 && alpha < 1), ...
    'MATLAB:corrcoef:invalidAlpha', ...
    'The ''alpha'' parameter must be a scalar between 0 and 1.');
userows = eml_get_parameter_value(pstruct.rows,'all',varargin{:});
eml_lib_assert(~logical(pstruct.rows) || (ischar(userows) && ( ...
    eml_partial_strcmp('all',eml_tolower(userows)) || ...
    eml_partial_strcmp('complete',eml_tolower(userows)) || ...
    eml_partial_strcmp('pairwise',eml_tolower(userows)))), ...
    'MATLAB:corrcoef:invalidRowChoice', ...
    'Valid row choices are ''all'', ''complete'', and ''pairwise''.');
% Compute correlations.
if CALC_P
    p = eml.nullcopy(zeros(nr,class(x)));
    if CALC_CONF
        rlo = eml.nullcopy(p);
        rup = eml.nullcopy(p);
        palpha = -erfinv(alpha-1)*sqrt(2);
    end
end
if isequal(userows,'pairwise')
    % Compute correlation for each pair.
    r = eml.nullcopy(eml_expand(eml_scalar_eg(x),[nr,nr]));
    isnanx = isnan(x);
    for k = 1:nr
        r(k,k) = corrcoef_pairwise(x,isnanx,k,k);
        if CALC_P
            p(k,k) = r(k,k);
            if CALC_CONF
                rlo(k,k) = r(k,k);
                rup(k,k) = r(k,k);
            end
        end
        for j = eml_index_plus(k,1):nr;
            [r(j,k),n] = corrcoef_pairwise(x,isnanx,j,k);
            r(k,j) = conj(r(j,k));
            if CALC_P
                nx = cast(n,class(x));
                if CALC_CONF
                    [p(j,k),rlo(j,k),rup(j,k)] = calcp(r(j,k),nx,palpha);
                    rlo(k,j) = rlo(j,k);
                    rup(k,j) = rup(j,k);
                else
                    p(j,k) = calcp(r(j,k),nx);
                end
                p(k,j) = p(j,k);
            end
        end
    end
else
    if isequal(userows,'all')
        [r,n] = corrcoef_all(x);
    elseif isequal(userows,'complete')
        % Remove observations with missing values.
        [r,n] = corrcoef_complete(x);
    end
    if CALC_P
        nx = cast(n,class(x));
        for k = 1:nr
            p(k,k) = r(k,k);
            if CALC_CONF
                rlo(k,k) = r(k,k);
                rup(k,k) = r(k,k);
            end
            for j = eml_index_plus(k,1):nr
                if CALC_CONF
                    [p(j,k),rlo(j,k),rup(j,k)] = calcp(r(j,k),nx,palpha);
                    rlo(k,j) = rlo(j,k);
                    rup(k,j) = rup(j,k);
                else
                    p(j,k) = calcp(r(j,k),nx);
                end
                p(k,j) = p(j,k);
            end
        end
    end
end

%--------------------------------------------------------------------------

function [p,rlo,rup] = calcp(rv,nv,palpha)
% Compute p value from rv and nv.  If nargout > 1, calculates the
% confidence interval, where palpha = -erfinv(alpha-1)*sqrt(2).
% Tstat = +/-Inf and p = 0 if abs(r) == 1, NaN if r == NaN.
Tstat = rv*sqrt((nv - 2)/(1 - rv*rv));
p = 2*tpvalue(-abs(Tstat),nv-2);
if nargout > 1
    % Compute confidence bound if requested.
    % Confidence bounds are degenerate if abs(r) = 1, NaN if r = NaN.
    z = 0.5*log((1 + rv)/(1 - rv));
    if nv > 3
        zalpha = cast(palpha/sqrt(nv-3),class(rv));
    else
        zalpha = eml_guarded_nan(class(rv));
    end
    rlo = tanh(z-zalpha);
    rup = tanh(z+zalpha);
end

%--------------------------------------------------------------------------

function p = tpvalue(x,v)
% Compute p-value for t statistic.
normcutoff = 1e7;
if isnan(x) || ~(0<v); % v == NaN ==> (0<v) == false
    p = eml_guarded_nan(class(x));
else
    % First compute F(-|x|).
    if v == 1
        % Cauchy distribution.  See Devroye pages 29 and 450.
        p = .5 + atan(x)/pi;
    elseif v > normcutoff
        % Normal Approximation.
        p = 0.5 * erfc(-x/sqrt(2));
    else
        % See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1.
        p = real(betainc(v/(v + x*x),v/2,0.5)/2);
        % Adjust for x>0.  Right now p<0.5, so this is numerically safe.
        if x > 0
            p = 1 - p;
        end
    end
    % Make the result exact for the median.
    if x == 0
        p = cast(0.5,class(x));
    end
end

%--------------------------------------------------------------------------

function r = cov_to_corrcoef(r)
% Compute the correlation coefficient matrix given the covariance matrix.
m = cast(size(r,1),eml_index_class);
d = eml.nullcopy(eml_expand(eml_scalar_eg(r),[m,1]));
for k = 1:m
    d(k) = sqrt(r(k,k));
end
for j = 1:m
    for i = eml_index_plus(j,1):m
        r(i,j) = (r(i,j) / d(i)) / d(j);
    end
    % Fix up possible round-off problems, while preserving NaN: put
    % exact 1 on the diagonal, and limit off-diag to [-1,1].
    for i = eml_index_plus(j,1):m
        absrij = abs(r(i,j));
        if absrij > 1
            r(i,j) = r(i,j) / absrij;
        end
        r(j,i) = conj(r(i,j));
    end
    if r(j,j) > 0
        r(j,j) = sign(r(j,j));
    else
        r(j,j) = eml_guarded_nan;
    end
end

%--------------------------------------------------------------------------

function [r,m] = corrcoef_all(x)
% Returns the lower triangle of cov(x).
fm = cast(size(x,1),class(x));
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
xzero = eml_scalar_eg(x);
xy = eml_expand(xzero,[n,n]);
if m < 2
    xy(:) = eml_guarded_nan;
else
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
    fm = fm - 1;
    for j = 1:n
        d = real(xzero);
        for k = 1:m
            d = d + real(x(k,j))*real(x(k,j)) + imag(x(k,j))*imag(x(k,j));
        end
        xy(j,j) = d / fm;
        for i = eml_index_plus(j,1):n
            s = xzero;
            for k = 1:m
                s = s + eml_conjtimes(x(k,i),x(k,j));
            end
            xy(i,j) = s / fm;
        end
    end
end
r = cov_to_corrcoef(xy);

%--------------------------------------------------------------------------

function [r,mu] = corrcoef_complete(x)
% Returns the lower triangle of the correlation coefficient matrix after
% stripping x down just to the rows with no NaNs.
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
xzero = eml_scalar_eg(x);
userow = true(size(x,1),1);
mu = cast(m,eml_index_class);
for j = 1:n
    for i = 1:m
        if userow(i) && isnan(x(i,j))
            userow(i) = false;
            mu = eml_index_minus(mu,1);
        end
    end
end
xy = eml_expand(xzero,[n,n]);
if mu < 2
    xy(:) = eml_guarded_nan;
else
    fm = cast(mu,class(x));
    for j = 1:n
        s = xzero;
        for k = 1:m
            if userow(k)
                s = s + x(k,j);
            end
        end
        s = s / fm;
        for k = 1:m
            if userow(k)
                x(k,j) = x(k,j) - s;
            end
        end
    end
    fm = fm - 1;
    for j = 1:n
        d = zeros(class(x));
        for k = 1:m
            if userow(k)
                d = d + real(x(k,j))*real(x(k,j)) + ...
                    imag(x(k,j))*imag(x(k,j));
            end
        end
        xy(j,j) = d / fm;
        for i = eml_index_plus(j,1):n
            s = xzero;
            for k = 1:m
                if userow(k)
                    s = s + eml_conjtimes(x(k,i),x(k,j));
                end
            end
            xy(i,j) = s / fm;
        end
    end
end
r = cov_to_corrcoef(xy);

%--------------------------------------------------------------------------

function [r,mu] = corrcoef_pairwise(x,isnanx,ri,rj)
% Returns the (ri,rj) element of the correlation coefficient matrix,
% where it is assumed that ri >= rj.  The isnanx argument should be
% isnan(x), precomputed for efficiency.
m = cast(size(x,1),eml_index_class);
xzero = eml_scalar_eg(x);
mu = zeros(eml_index_class);
if ri == rj
    % If there is no variation, return NaN.
    sumdiff = zeros(class(x));
    if m > 1
        % Skip forward to first non-nan value.  Use it as a reference value
        % to determine if there is any variation.
        k = zeros(eml_index_class);
        while k < m
            k = eml_index_plus(k,1);
            if ~isnan(x(k,ri))
                mu = ones(eml_index_class);
                x0 = x(k,ri);
                while k < m
                    k = eml_index_plus(k,1);
                    if ~isnanx(k,ri)
                        sumdiff = sumdiff + abs(x(k,ri) - x0);
                        mu = eml_index_plus(mu,1);
                    end
                end
            end
        end
    end
    if mu > 1 && sumdiff > 0
        r = xzero + 1;
    else
        r = xzero + eml_guarded_nan;
    end
else
    sri = xzero;
    srj = xzero;
    for k = 1:m
        if ~(isnanx(k,ri) || isnanx(k,rj))
            sri = sri + x(k,ri);
            srj = srj + x(k,rj);
            mu = eml_index_plus(mu,1);
        end
    end
    if mu < 2
        r = xzero + eml_guarded_nan;
    else
        fm = cast(mu,class(x));
        sri = sri / fm;
        srj = srj / fm;
        d1 = zeros(class(xzero));
        d2 = zeros(class(xzero));
        r = xzero;
        for k = 1:m
            if ~(isnanx(k,ri) || isnanx(k,rj));
                a = x(k,ri) - sri;
                b = x(k,rj) - srj;
                d1 = d1 + real(a)*real(a) + imag(a)*imag(a);
                r = r + eml_conjtimes(a,b);
                d2 = d2 + real(b)*real(b) + imag(b)*imag(b);
            end
        end
        fm = fm - 1;
        d1 = sqrt(d1 / fm);
        d2 = sqrt(d2 / fm);
        r = ((r / fm) / d1) / d2;
        absr = abs(r);
        if absr > 1
            r = r / absr;
        end
    end
end
%--------------------------------------------------------------------------
