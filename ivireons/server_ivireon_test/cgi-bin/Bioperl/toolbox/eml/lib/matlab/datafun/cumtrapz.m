function z = cumtrapz(x,y,dim)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float') || islogical(x), ...
    ['Function ''cumtrapz'' is not defined for values of class ''' class(x) '''.']);
if nargin == 3
    z = trapwork(true,x,y,dim);
elseif nargin == 2
    if eml_is_const(size(y)) && isscalar(y) % cumtrapz(x,y) corresponds to cumtrapz(y,dim)
        z = trapwork(false,zeros(0,class(x)),x,y);
    else
        z = trapwork(true,x,y);
    end
else
    z = trapwork(false,zeros(0,class(x)),x);
end

%--------------------------------------------------------------------------

function z = trapwork(givenx,x,y,dim)
eml_must_inline;
eml_assert(isa(y,'float') || islogical(y), ...
    ['Function ''cumtrapz'' is not defined for values of class ''' class(y) '''.']);
ONE = ones(eml_index_class);
if nargin < 4
    dim = eml_nonsingleton_dim(y);
else
    eml_prefer_const(dim);
    eml_assert_valid_dim(dim);
end
vlen = size(y,dim);
if givenx
    % In this case DIM must be a constant when not variable sizing.
    if nargin < 4
        eml_lib_assert(eml_numel(x) == vlen, ...
            'MATLAB:cumtrapz:LengthXMismatchY', ...
            'numel(x) must equal the length of the first non-singleton dimension of y.');
    else
        eml_lib_assert(eml_numel(x) == vlen, ...
            'MATLAB:cumtrapz:LengthXMismatchY', ...
            'numel(x) must equal the length of the DIM''th dimension of Y.');
    end
    for i = ONE:eml_index_minus(vlen,1)
        x(i) = x(i+1) - x(i);
    end
end
zzero = eml_scalar_eg(x,y);
if isempty(y)
    eml_assert(eml_is_const(dim) || eml_option('VariableSizing'), ...
        'DIM argument must be a constant.');
    if vlen == 0
        sz = size(y);
        sz(dim) = 1;
        z = eml_expand(zzero,sz);
    else
        z = eml_expand(zzero,size(y));
    end 
else
    z = eml.nullcopy(eml_expand(zzero,size(y)));
    vstride = eml_matrix_vstride(y,dim);
    npages = eml_matrix_npages(y,dim);
    ZERO = zeros(eml_index_class);
    iyz = ZERO;
    for i = 1:npages
        iystart = iyz;
        for j = 1:vstride
            iystart = eml_index_plus(iystart,1);
            s = zzero;
            ix = ZERO;
            iyz = iystart;
            ylast = y(iyz);
            z(iyz) = 0;
            for k = 2:vlen
                iyz = eml_index_plus(iyz,vstride);
                if isempty(x)
                    s = s + eml_div(ylast+y(iyz),2);
                else
                    ix = eml_index_plus(ix,1);
                    s = s + x(ix)*eml_div(ylast+y(iyz),2);
                end
                ylast = y(iyz);
                z(iyz) = s;
            end
        end
    end
end

%--------------------------------------------------------------------------
