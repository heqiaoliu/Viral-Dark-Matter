function [M,F,C] = mode(x,dim)
%Embedded MATLAB Library Function

%   Limitations:
%       The third output argument is not supported.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments');
eml_assert(nargout < 3, 'Third output is not supported.'); C = 0; % To calm MLINT.
eml_assert(isa(x,'float'), ...
    ['Function ''mode'' is not defined for values of class ''' class(x) '''.']);
xzero = eml_scalar_eg(x);
if nargin < 2
    if eml_is_const(size(x)) && isequal(x,[])
        M = eml_guarded_nan(class(x)) + xzero;
        F = 0;
        % C = {zeros(0,1,class(x))};
        eml_warning('MATLAB:mode:EmptyInput', ...
            ['MODE of a 0-by-0 matrix is NaN; result was an empty ', ...
            'matrix in previous releases.'])
        return
    end
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:mode:specialEmpty', ...
        'MODE with one variable-size matrix argument of [] is not supported.');
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:mode:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
if size(x,dim) == 1 % Covers dim > ndims(x) case.
    M = x;
    F = ones(size(x));
    return
end
sz = size(x);
sz(dim) = 1;
M = eml.nullcopy(eml_expand(xzero,sz));
F = eml.nullcopy(zeros(sz));
if isempty(x) || eml_ambiguous_types
    F(:) = 0;
elseif isscalar(M)
    [M,F] = vectormode(x);
else
    vlen = size(x,dim);
    vwork = eml.nullcopy(eml_expand(xzero,[vlen,1]));
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages  = eml_matrix_npages(x,dim);
    i2 = zeros(eml_index_class);
    iy = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            % Copy x(i1:vstride:i2) to vwork.
            ix = i1;
            for k = 1:vlen
                vwork(k) = x(ix);
                ix = eml_index_plus(ix,vstride);
            end
            % Calculate median and store in y.
            [mtmp,ftmp] = vectormode(vwork);
            iy = eml_index_plus(iy,1);
            M(iy) = mtmp;
            F(iy) = ftmp;
        end
    end
end

%--------------------------------------------------------------------------

function [m,fd] = vectormode(v)
% Mode of a vector with corresponding frequency.
ONE = ones(eml_index_class);
v = sort(v);
m = v(1);
f = ONE;
mtmp = m;
ftmp = ONE;
for k = 2:eml_numel(v)
    if v(k) == mtmp
        ftmp = eml_index_plus(ftmp,ONE);
    else
        if ftmp > f
            m = mtmp;
            f = ftmp;
        end
        mtmp = v(k);
        ftmp = ONE;
    end
end
if ftmp > f
    m = mtmp;
    f = ftmp;
end
fd = double(f);

%--------------------------------------------------------------------------
