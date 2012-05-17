function x = eml_ifftshift(x,dim)
%Embedded MATLAB Private Function

%   IFFTSHIFT of X along dimension DIM.  DIM is not validated.

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments');
eml_prefer_const(dim);
if dim > ndims(x)
    return
end
vlen = size(x,dim);
if vlen <= 1
    return
end
vlend2 = eml_index_rdivide(vlen,2);
if eml_index_times(vlend2,2) == vlen
    % Even length dimensions are handled with eml_fftshift.
    x = eml_fftshift(x,dim);
    return
end
vstride = eml_matrix_vstride(x,dim);
npages = eml_matrix_npages(x,dim);
vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
midoffset = eml_index_times(vlend2,vstride);
i2 = zeros(eml_index_class);
for i = 1:npages
    i1 = i2;
    i2 = eml_index_plus(i2,vspread);
    for j = 1:vstride
        i1 = eml_index_plus(i1,1);
        i2 = eml_index_plus(i2,1);
        % Unshift x(i1:vstride:i2))
        ia = eml_index_plus(i1,midoffset);
        ib = i2;
        xtmp = x(ib);
        for k = 1:vlend2
            ia = eml_index_minus(ia,vstride);
            ic = ib;
            ib = eml_index_minus(ic,vstride);
            x(ic) = x(ia);
            x(ia) = x(ib);
        end
        x(ib) = xtmp;
    end
end
