function y = nchoosek(x,k)
%Embedded MATLAB Library Function

%   Limitations:  Does not support variable-size inputs.

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(eml_is_const(size(x)) && eml_is_const(size(k)), ...
    'Inputs must be fixed-size.');
eml_assert(isscalar(x) || isvector(x), ...
    'The first argument has to be a scalar or a vector.');
eml_assert(isscalar(k) && isreal(k), ...
    'The second input has to be a non-negative integer.');
n = eml_numel(x);
if k < 0 || k ~= floor(k)
    eml_error('MATLAB:nchoosek:InvalidArg2','The second input has to be a non-negative integer.');
    k = zeros(class(k));
end
if isscalar(x) && isa(x,'float') && isa(k,'float')
    if k > x
        eml_error('MATLAB:nchoosek:KOutOfRange','K must be an integer between 0 and N.');
        k = zeros(class(k));
    end
    y = nCk(x,k);
elseif k > eml_numel(x)
    y = eml_expand(eml_scalar_eg(x),[0,k]);
else
    ONE = ones(eml_index_class);
    nint = eml_cast(n,eml_index_class,'to zero','wrap');
    kint = eml_cast(k,eml_index_class,'to zero','wrap');
    nrows = eml_cast(nCk(n,double(k)),eml_index_class,'to zero','wrap');
    y = eml.nullcopy(eml_expand(eml_scalar_eg(x),[nrows,kint]));
    comb = ONE:kint;
    icomb = kint; % index into comb
    nmkpi = nint; % n-k+i
    for row = ONE:nrows
        for col = ONE:kint
            y(row,col) = x(comb(col));
        end
        % Compute the next combination of n things taken k at a time.
        % The "first" combination should be 1:k.  The "last" combination
        % will be (n-k+1):n.
        if icomb > 0
            combj = eml_index_plus(comb(icomb),ONE);
            comb(icomb) = combj;
            if combj < nmkpi
                for j = eml_index_plus(icomb,ONE):kint
                    combj = eml_index_plus(combj,ONE);
                    comb(j) = combj;
                end
                icomb = kint;
                nmkpi = nint;
            else
                icomb = eml_index_minus(icomb,ONE);
                nmkpi = eml_index_minus(nmkpi,ONE);
            end
        end
    end
end

%--------------------------------------------------------------------------

function y = nCk(n,k)
% n!/(k!*(n-k)!), 0 <= k <= n.
if ~isa(k,class(n))
    y = nCk(single(n),single(k));
    return
elseif isfinite(n) && isfinite(k)
    if k > eml_rdivide(n,2)
        k = n - k;
    end
    if k > 1000
        y = eml_guarded_inf(class(n));
    else
        y = ones(class(n));
        nmk = n - k;
        for j = 1:k
            y = y * eml_rdivide(j+nmk,j);
        end
        y = round(y);
    end
else
    y = eml_guarded_nan(class(n));
end
if ~isfinite(y) || eps(y) > 0.25
    eml_warning('MATLAB:nchoosek:LargeCoefficient','Result may not be exact.');
end

%--------------------------------------------------------------------------
