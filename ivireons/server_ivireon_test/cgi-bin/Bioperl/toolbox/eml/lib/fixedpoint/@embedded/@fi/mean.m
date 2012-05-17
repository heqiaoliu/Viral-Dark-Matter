function yout = mean(x, dimx)%#eml
%MEAN   Fixed-point mean function for Embedded MATLAB
%
%   Y = MEAN(X) computes the mean value of the elements in FI array X along
%   its first non-singleton dimension.
%
%   Y = MEAN(X, DIM) computes the mean value of the elements in FI array X 
%   along dimension DIM.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/09/09 21:06:37 $

eml.extrinsic('strcmpi');
eml_assert(nargin > 0, 'Not enough input arguments.');

isnumin1 = (nargin == 1);
if isnumin1
    
    dimx = 1;
end
eml_statop_input_and_index_checks(x, 'mean', dimx);
    
dim = eml_statop_validate_and_get_dim(x, isnumin1, dimx);
isconstEmptyX = isempty(x)&&eml_is_const(isempty(x));
isconstNoSum1 = (dim > ndims(x))&&eml_is_const(dim > ndims(x));
isconstNoSum2 = (size(x,dim) == 1)&&eml_is_const(size(x,dim) == 1);
isconstNoSum = (isconstNoSum1||isconstNoSum2);
if ~eml_is_const(size(x))&&~isfloat(x)&&~isconstEmptyX&&~isconstNoSum
    
    fmx = eml_const(eml_fimath(x));
    smmodex = eml_const(get(fmx, 'summode'));
    issmmodespecprec = eml_const(strcmpi(smmodex,'specifyprecision'));
    issmmodekeeplsb = eml_const(strcmpi(smmodex,'keeplsb'));    
    eml_lib_assert((issmmodespecprec||issmmodekeeplsb), 'fi:mean:unsupportedSumMode',...
        ['Embedded MATLAB only supports SumModes ''SpecifyPrecision'' and ' ...
           '''KeepLSB'' for ''mean'' when the size of the input can vary ' ...
           'at run-time.']);
end
ty = eml_const(numerictype(x));
if isfloat(x)
    
    xtemp = eml_cast(x, eml_fi_getDType(x));
    xmean = mean(xtemp, eml_cast(dim,'double'));
    y = eml_cast(xmean,ty);
elseif isconstEmptyX
    
    y = eml_statop_empty_handling(x, isnumin1, ty, dim);
else
    
    xscalar = eml_scalar_eg(x);
    xfull = eml.nullcopy(eml_expand(xscalar,size(x)));
    y = eml.nullcopy(eml_expand(xscalar,size(sum(xfull,dim))));
    if (dim > ndims(x))||(size(x,dim) == 1)
    
        y(:) = x;    
    else

        sumx = sum(x, dim);
        szx = fi(size(x, dim), false, 32, 0);
        y(:) = divide(ty, sumx, szx);
    
    end
end
yout =  eml_fimathislocal(y, false);


