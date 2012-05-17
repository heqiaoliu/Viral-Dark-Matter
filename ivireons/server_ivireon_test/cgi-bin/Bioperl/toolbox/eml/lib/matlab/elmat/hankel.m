function H = hankel(c,r)
%Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(c,'numeric'), 'First input must be numeric.');
eml_lib_assert(~isempty(c),...
    'EmbeddedMATLAB:hankel:emptyC', ...
    'First input must not be empty.');
nrows = cast(eml_numel(c),eml_index_class);
if nargin == 2
    eml_assert(isa(r,'numeric'), 'Second input must be numeric.');
    eml_assert(isa(r,class(c)) || ( ...
        (~isinteger(c) || (isa(r,'double') && eml_is_const(isscalar(r)) && isscalar(r))) && ...
        (~isinteger(r) || (isa(c,'double') && eml_is_const(isscalar(c)) && isscalar(c)))), ...
            'Integers can only be combined with integers of the same class, or scalar doubles.');
    eml_lib_assert(~isempty(c),...
        'EmbeddedMATLAB:hankel:emptyR', ...
        'Second input must not be empty.');
    if c(nrows) ~= r(1)
        eml_warning('MATLAB:hankel:AntiDiagonalConflict',['Last element of ' ...
            'input column does not match first element of input row. ' ...
            '\n         Column wins anti-diagonal conflict.'])
    end
    hzero = eml_scalar_eg(c,r);
    ncols = cast(eml_numel(r),eml_index_class);
else
    hzero = eml_scalar_eg(c);
    ncols = nrows;
end
ONE = ones(eml_index_class);
H = eml.nullcopy(eml_expand(hzero,[nrows,ncols]));
for j = ONE:min(nrows,ncols)
    jm1 = eml_index_minus(j,ONE);
    istop = eml_index_minus(nrows,jm1);
    for i = ONE:istop
        H(i,j) = c(eml_index_plus(i,jm1));
    end
    for i = eml_index_plus(istop,ONE):nrows
        if nargin == 2
            H(i,j) = r(eml_index_plus(eml_index_minus(i,istop),ONE));
        else
            H(i,j) = hzero;
        end
    end
end
for j = eml_index_plus(nrows,1):ncols
    jmnrows = eml_index_minus(j,nrows);
    for i = ONE:nrows
        if nargin == 2
            H(i,j) = r(eml_index_plus(i,jmnrows));
        else
            H(i,j) = hzero;
        end
    end
end
