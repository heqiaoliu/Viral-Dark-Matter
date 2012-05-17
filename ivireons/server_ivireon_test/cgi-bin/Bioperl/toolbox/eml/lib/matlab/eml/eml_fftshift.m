function x = eml_fftshift(x,dim)
%Embedded MATLAB Private Function

%   FFTSHIFT of X along dimension DIM.  DIM is not validated.

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
vstride = eml_matrix_vstride(x,dim);
npages = eml_matrix_npages(x,dim);
vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
midoffset = eml_index_times(vlend2,vstride);
if eml_index_times(vlend2,2) == vlen
    % Handle even length dimension.
    i2 = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            % Shift x(i1:vstride:i2)
            ia = i1;
            ib = eml_index_plus(i1,midoffset);
            for k = 1:vlend2
                tmp = x(ia);
                x(ia) = x(ib);
                x(ib) = tmp;
                ia = eml_index_plus(ia,vstride);
                ib = eml_index_plus(ib,vstride);
            end
        end
    end
else
    % Handle odd length dimension.
    i2 = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            % Shift x(i1:vstride:i2))
            ia = i1;
            ib = eml_index_plus(i1,midoffset);
            xtmp = x(ib);
            for k = 1:vlend2
                ic = eml_index_plus(ib,vstride);
                x(ib) = x(ia);
                x(ia) = x(ic);                
                ia = eml_index_plus(ia,vstride);
                ib = ic;
            end
            x(ib) = xtmp;
        end
    end
end   
