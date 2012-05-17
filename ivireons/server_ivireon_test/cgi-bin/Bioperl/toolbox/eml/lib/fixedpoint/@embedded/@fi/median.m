function yout = median(x, dimx)%#eml
%MEDIAN Median value.
%
%   Y = MEDIAN(X) computes the median value of the elements in FI array X along
%   its first non-singleton dimension.
%
%   Y = MEDIAN(X, DIM) computes the median value of the elements in FI array X 
%   along dimension DIM.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:10:54 $

eml_assert(nargin > 0, 'Not enough input arguments.');

isnumin1 = (nargin == 1);
if isnumin1
    
    dimx = 1;
end
eml_statop_input_and_index_checks(x, 'median', dimx);
eml_lib_assert(isreal(x), 'fi:median:supportForRealOnly', 'Median only supports real-valued fixed-point input arrays.');
dim = eml_statop_validate_and_get_dim(x, isnumin1, dimx);

if dim > eml_ndims(x)
    
    y = x;
    yout = eml_fimathislocal(y,false);
    return;
end
sz = size(x);
sz(dim) = 1;
ty = numerictype(x);
tmp = eml.nullcopy(eml_expand(eml_scalar_eg(x),sz));
if isfloat(x)
    
    xtemp = eml_cast(x, eml_fi_getDType(x));
    xmedian = median(xtemp, eml_cast(dim,'double'));
    y = eml_cast(xmedian, ty);
elseif isempty(x) && eml_is_const(isempty(x)) 
    
    y = eml_statop_empty_handling(x, isnumin1, ty, dim);
elseif isscalar(tmp) && eml_is_const(isscalar(tmp))
    
    y = vectormedian(x);
else
    
    vlen = size(x,dim);
    y = tmp;
    
    vwork = eml.nullcopy(eml_expand(eml_scalar_eg(x),[vlen,1]));
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages = eml_matrix_npages(x,dim);
    i2 = zeros(eml_index_class);
    iy = zeros(eml_index_class);
    for i = 1:npages
        
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            % copy x(i1:vstride:i2) to vwork
            ix = i1;
            for k = 1:vlen
                
                vwork(k) = x(ix);
                ix = eml_index_plus(ix,vstride);
            end
            % Calculate median and store in y
            iy = eml_index_plus(iy,1);
            y(iy) = vectormedian(vwork);
        end
    end
end

yout = eml_fimathislocal(y,false);

function m = vectormedian(v)

eml.extrinsic('emlGetNTypeForPlus');

maxWL = eml_option('FixedPointWidthLimit');
vlen = eml_numel(v);
midm1 = eml_index_rdivide(vlen,2);
mid = eml_index_plus(midm1,1);
evenlength = (vlen == eml_index_times(midm1,2));

v = sort(v);
m = eml_scalar_eg(v);
tv = eml_const(numerictype(v));

if evenlength
    
    elem1 = v(midm1);
    elem2 = v(mid);    
    fm = eml_const(eml_fimath(v));
    tc = eml_const(emlGetNTypeForPlus(tv,tv,fm,maxWL));
    c = eml_plus(elem1, elem2, tc, fm);
    tcby2 = eml_const(numerictype(tc,'fractionlength',(tc.fractionlength+1)));    
    cscale = reinterpretcast(c, tcby2);
    m(:) = cscale;
else
    
    m = v(mid);
end

