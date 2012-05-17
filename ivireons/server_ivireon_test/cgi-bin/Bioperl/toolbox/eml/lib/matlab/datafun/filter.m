function [y,zf] = filter(b,a,x,zi,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 3, 'Not enough input arguments.');
eml_assert(isa(b,'float'), ...
    ['Function ''filter'' is not defined for values of class ''' ...
    class(b) '''.']);
eml_assert(eml_is_const(isvector(b)), ...
    ['First argument must be a vector with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(b), 'First argument must be a vector.');
eml_lib_assert(~isempty(b), ...
    'EmbeddedMATLAB:filter:notVectorInputB', ...
    'First argument must be a non-empty vector.');
eml_assert(isa(a,'float'), ...
    ['Function ''filter'' is not defined for values of class ''' ...
    class(a) '''.']);
eml_assert(eml_is_const(isvector(a)), ...
    ['Second argument must be a vector with at most one ', ...
    'variable-length dimension, the first dimension or the second. ', ...
    'All other dimensions must have a fixed length of 1.']);
eml_assert(isvector(a), 'Second argument must be a vector.');
eml_lib_assert(~isempty(a), ...
    'EmbeddedMATLAB:filter:secondInputNotVector', ...
    'Second argument must be a non-empty vector.');
eml_assert(isa(x,'float'), ...
    ['Function ''filter'' is not defined for values of class ''' ...
    class(x) '''.']);
ZIEMPTY  = 0;
ZIVECTOR = 1;
ZIMATRIX = 2;
na = eml_numel(a);
nb = eml_numel(b);
ndbuffer = max(na,nb);
ndbufferm1 = ndbuffer-1;
if nargin < 4
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:filter:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
    bazitype = eml_scalar_eg(b,a);
    zi = zeros(0,class(bazitype));
    zicase = ZIEMPTY;
else
    eml_assert(isa(zi,'float'), ...
        ['Function ''filter'' is not defined for values of class ''' ...
        class(zi) '''.']);
    if nargin < 5
        dim = eml_const_nonsingleton_dim(x);
        eml_lib_assert(eml_is_const(size(x,dim)) || ...
            isscalar(x) || ...
            size(x,dim) ~= 1, ...
            'EmbeddedMATLAB:filter:autoDimIncompatibility', ...
            ['The working dimension was selected automatically, is ', ...
            'variable-length, and has length 1 at run-time. This is not ', ...
            'supported. Manually select the working dimension by ', ...
            'supplying the DIM argument.']);
    else
        eml_assert(eml_is_const(dim), ...
            'Dimension argument must be a constant.');
        eml_assert_valid_dim(dim);
        if dim > 1
            p = eml_const(eml_dim_to_fore_permutation(eml_ndims(x),dim));
            % Recurse with the permuted input and dim == 1.
            [y1,zf] = filter(b,a,permute(x,p),zi,1);
            % Apply the inverse permutation to y1 to obtain y.
            y = ipermute(y1,p);
            return
        end
    end
    if eml_is_const(isvector(zi)) && isvector(zi)
        zicase = ZIVECTOR;
        zi_size_ok = eml_numel(zi) == ndbufferm1;
    elseif eml_is_const(isempty(zi)) && isempty(zi)
        zicase = ZIEMPTY;
        zi_size_ok = true;
    else
        zicase = ZIMATRIX;
        zi_size_ok = compatible_zi_size(x,zi,ndbufferm1);
    end
    bazitype = eml_scalar_eg(b,a,zi);
    eml_lib_assert(zi_size_ok, ...
        'MATLAB:filter:invalidInitialConditions', ...
        ['Initial conditions must be a vector of length max(length(a),length(b))-1,\n', ...
        'or an array with the leading dimension of size max(length(a),length(b))-1\n', ...
        'and with remaining dimensions matching those of x.']);
end
if isreal(b) && ~isreal(a)
    if imag(a(1)) ~= 0
        % Make b complex first so that we can perform b = b ./ a(1).
        [y,zf] = filter(complex(b),a,x,zi,dim);
        return
    end
    a1 = real(a(1));
else
    a1 = a(1);
end
if ~isfinite(a1)
    eml_error('MATLAB:filter:firstElementOfDenominatorFilterNotFinite', ...
        'First denominator filter coefficient must be finite.');
elseif a1 == 0
    eml_error('MATLAB:filter:firstElementOfDenominatorFilterZero', ...
        'First denominator filter coefficient must be non-zero.');
elseif a1 ~= 1
    % Normalize a and b.
    for k = 1:nb
        b(k) = eml_div(b(k),a1);
    end
    for k = 2:na
        a(k) = eml_div(a(k),a1);
    end
    a(1) = 1;
end
y = eml.nullcopy(eml_expand(eml_scalar_eg(x,bazitype),size(x)));
nx = size(x,dim);
nc = eml_prodsize_except_dim(x,dim);
if eml_is_const(isvector(x)) && isvector(x)
    size_zf = [ndbufferm1,nc];
else
    size_zf = size(x);
    size_zf(1) = ndbufferm1;
end
zf = eml.nullcopy(eml_expand(eml_scalar_eg(y),size_zf));
offset = zeros(eml_index_class);
for c = 1:nc
    % Initialize delay buffer.
    dbuffer = eml.nullcopy(eml_expand(eml_scalar_eg(y),[ndbuffer,1]));
    if zicase == ZIMATRIX
        for k = 1:ndbufferm1
            dbuffer(k+1) = zi(k,c);
        end
    elseif zicase == ZIVECTOR
        for k = 1:ndbufferm1
            dbuffer(k+1) = zi(k);
        end
    else
        for k = 1:ndbufferm1
            dbuffer(k+1) = 0;
        end
    end
    % Apply filter.
    for j = 1:nx
        jp = eml_index_plus(j,offset);
        for k = 1:ndbufferm1
            dbuffer(k) = dbuffer(k+1);
        end
        dbuffer(ndbuffer) = 0;
        for k = 1:nb
            dbuffer(k) = dbuffer(k) + x(jp)*b(k);
        end
        for k = 2:na
            dbuffer(k) = dbuffer(k) - dbuffer(1)*a(k);
        end
        y(jp) = dbuffer(1);
    end
    for k = 1:ndbufferm1
        zf(k,c) = dbuffer(k+1);
    end
    offset = eml_index_plus(offset,nx);
end

%--------------------------------------------------------------------------

function p = compatible_zi_size(x,zi,ndbm1)
% A predicate to determine whether the zi size is compatible with x when zi
% is a matrix.
eml_prefer_const(ndbm1);
if size(zi,1) ~= ndbm1
    p = false;
    return
end
if eml_ndims(zi) == 2 % Legacy behavior.
    p = eml_size_prod(x,2) == size(zi,2);
    return
end
for k = eml.unroll(2:max(eml_ndims(x),eml_ndims(zi)))
    if size(x,k) ~= size(zi,k)
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------
