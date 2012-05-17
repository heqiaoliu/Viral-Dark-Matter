function x = cumprod(x,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''cumprod'' is not defined for values of class ''' class(x) '''.']);
if nargin == 1
    dim = eml_nonsingleton_dim(x);
else
    eml_prefer_const(dim);
    eml_assert_valid_dim(dim);
end
vlen = size(x,dim);
if ~isempty(x) && dim <= ndims(x) && vlen > 1
    vstride = eml_matrix_vstride(x,dim);
    npages = eml_matrix_npages(x,dim);
    ix = zeros(eml_index_class);
    for i = 1:npages
        ixstart = ix;
        for j = 1:vstride
            ixstart = eml_index_plus(ixstart,1);
            ix = ixstart;
            xlast = x(ix);
            for k = 2:vlen
                ix = eml_index_plus(ix,vstride);
                xlast = xlast * x(ix);
                x(ix) = xlast;
            end
        end
    end
end