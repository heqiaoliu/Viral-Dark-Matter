function z = trapz(x,y,dim)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float') || islogical(x), ...
    ['Function ''trapz'' is not defined for values of class ''' class(x) '''.']);
if nargin == 3 % trapz(x,y,dim)
    z = trapwork(true,x,y,dim);
elseif nargin == 2
    if eml_is_const(size(y)) && isscalar(y) % trapz(x,y) corresponds to trapz(y,dim)
        z = trapwork(false,zeros(0,class(x)),x,y); % y = x and dim = y implicitly
    else
        z = trapwork(true,x,y);
    end
elseif eml_is_const(size(x)) && isequal(x,[])
    z = eml_scalar_eg(x);
else
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:trapz:specialEmpty', ...
        'TRAPZ with one variable-size matrix input of [] is not supported.');
    z = trapwork(false,zeros(0,class(x)),x);
end

%--------------------------------------------------------------------------

function z = trapwork(givenx,x,y,dim)
eml_must_inline;
eml_assert(isa(y,'float') || islogical(y), ...
    ['Function ''trapz'' is not defined for values of class ''' class(y) '''.']);
zZERO = eml_scalar_eg(x,y);
if nargin < 4
    dim = eml_const_nonsingleton_dim(y);
    eml_lib_assert(eml_is_const(size(y,dim)) || ...
        isscalar(y) || ...
        size(y,dim) ~= 1, ...
        'EmbeddedMATLAB:trapz:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
vlen = size(y,dim);
if givenx
    if nargin < 4
        eml_lib_assert(eml_numel(x) == vlen, ...
            'MATLAB:trapz:LengthXmismatchY', ...
            'numel(x) must equal the length of the first non-singleton dimension of y.');
    else
        eml_lib_assert(eml_numel(x) == vlen, ...
            'MATLAB:trapz:LengthXmismatchY', ...
            'numel(x) must equal the length of the DIM''th dimension of Y.');
    end
    for i = ones(eml_index_class):vlen-1
        x(i) = x(i+1) - x(i);
    end
end
if eml_is_const(size(y,dim)) && size(y,dim) == 1
    z = eml_expand(zZERO,size(y));
    return
end
sz = size(y);
sz(dim) = 1;
z = eml.nullcopy(eml_expand(zZERO,sz));
if isempty(y)
    z(:) = zZERO;
    return
end
vstride = eml_matrix_vstride(y,dim);
npages = eml_matrix_npages(y,dim);
iZERO = zeros(eml_index_class);
iy = iZERO;
iz = iZERO;
for i = 1:npages
    iystart = iy;
    for j = 1:vstride
        iystart = eml_index_plus(iystart,1);
        s = zZERO;
        ix = iZERO;
        iy = iystart;
        ylast = y(iy);
        for k = 2:vlen
            iy = eml_index_plus(iy,vstride);
            if isempty(x)
                s = s + eml_div(ylast+y(iy),2);
            else
                ix = eml_index_plus(ix,1);
                s = s + x(ix)*eml_div(ylast+y(iy),2);
            end
            ylast = y(iy);
        end
        iz = eml_index_plus(iz,1);
        z(iz) = s;
    end
end

%--------------------------------------------------------------------------
