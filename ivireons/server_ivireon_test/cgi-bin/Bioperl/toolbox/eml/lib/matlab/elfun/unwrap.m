function p = unwrap(p,cutoff,dim)
%Embedded MATLAB Library Function

%   Limitations:  Single precision results may differ from MATLAB due to
%   different rounding errors.  When the result is single precision,
%   Embedded MATLAB does all intermediate calculations in single precision.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(p,'float'), ...
    'First input must be ''double'' or ''single''.');
if nargin < 2 || eml_is_const(size(cutoff)) && isempty(cutoff)
    cut = cast(pi,class(p));
else
    eml_assert(isscalar(cutoff) && isa(cutoff,'float'), ...
        'Second input must be a floating point scalar or [].');
    cut = cutoff;
end
if nargin < 3
    dim = eml_nonsingleton_dim(p);
else
    eml_assert_valid_dim(dim);
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim) || eml_option('VariableSizing'), ...
        'Dimension argument must be a constant.');
end
vlen = size(p,dim);
vwork = eml.nullcopy(eml_expand(eml_scalar_eg(p),[vlen,1]));
if eml_is_const(isvector(p)) && isvector(p) && eml_is_const(dim) && ( ...
        (dim == 1 && eml_is_const(size(p,2)) && size(p,2) == 1) || ...
        (dim == 2 && eml_is_const(size(p,1)) && size(p,1) == 1))
    p = unwrap_vector(p,cut);
else
    vstride = eml_matrix_vstride(p,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages  = eml_matrix_npages(p,dim);
    i2 = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            % Copy p(i1:vstride:i2) to vwork.
            ip = i1;
            for k = 1:vlen
                vwork(k) = p(ip);
                ip = eml_index_plus(ip,vstride);
            end
            vwork = unwrap_vector(vwork,cut);
            % Copy vector into the output matrix.
            ip = i1;
            for k = 1:vlen
                p(ip) = vwork(k);
                ip = eml_index_plus(ip,vstride);
            end
        end
    end
end

%--------------------------------------------------------------------------

function p = unwrap_vector(p,cutoff)
% Unwrap phase angles.  Algorithm minimizes the incremental
% phase variation by constraining it to the range [-pi,pi]
ppi = cast(pi,class(p));
m = eml_numel(p);
cumsum_dp_corr = eml_scalar_eg(p);
% Seek first finite value.
k = 1;
while k < m && ~isfinite(p(k))
    k = k + 1;
end
if k < m
    pkm1 = p(k);
    while true
        % Seek next finite value.
        k = k + 1;
        while k <= m && ~isfinite(p(k))
            k = k + 1;
        end
        if k > m
            break
        end
        dp = p(k) - pkm1;
        % Equivalent phase variations in [-pi,pi)
        dps = mod(dp+ppi,2*ppi) - ppi;
        % Preserve variation sign for pi vs. -pi
        if dps == -ppi && dp > 0
            dps(1) = ppi;
        end
        if abs(dp) >= cutoff
            cumsum_dp_corr = cumsum_dp_corr + (dps - dp);
        end
        % Save p(k) for next iteration.
        pkm1 = p(k);
        % Add to P to produce smoothed phase values
        p(k) = p(k) + cumsum_dp_corr;
    end
end

%--------------------------------------------------------------------------