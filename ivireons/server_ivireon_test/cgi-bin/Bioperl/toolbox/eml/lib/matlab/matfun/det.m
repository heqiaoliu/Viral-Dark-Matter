function y = det(x)
%Embedded MATLAB Library Function

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Function ''det'' is not defined for values of class ''' class(x) '''.']);
eml_lib_assert(ndims(x) == 2 && size(x,1) == size(x,2), 'MATLAB:square', ...
    'Matrix must be square.');
if isempty(x)
    y = eml_scalar_eg(x) + 1;
    return
end
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
ONE = ones(eml_index_class);
[x,ipiv] = eml_xgetrf(m,n,x,ONE,m);
y = x(1,1);
for k = 2:size(x,1)
    y = y*x(k,k);
end
isodd = false;
for k = 1:eml_numel(ipiv)-1
    if ipiv(k) > k
        isodd = ~isodd;
    end
end
if isodd
    y = -y;
end
