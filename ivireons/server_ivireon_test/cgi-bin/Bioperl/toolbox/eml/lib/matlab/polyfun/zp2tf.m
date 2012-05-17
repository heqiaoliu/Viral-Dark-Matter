function [num,den] = zp2tf(z,p,k)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 3, 'Not enough input arguments.');
den = real(poly(p(:)));
[~,nd] = size(den);
mk = eml_numel(k);
[m,n] = size(z);
eml_lib_assert(mk == n || m ~= 1, ...
    'MATLAB:zp2tf:ZNotColumn', ...
    'Z must be a column vector.');
eml_lib_assert(mk == n || m == 1, ...
    'MATLAB:zp2tf:KMismatchZ',...
    'K must have as many elements as Z has columns.');
numcols = max(nd,m+1);
num = eml.nullcopy(eml_expand(eml_scalar_eg(z,k),[n,numcols]));
i0 = eml_index_minus(numcols,m);
for j = 1:n
    pj = real(poly(z(:,j))*k(j)); 
    % Since EML's POLY does not remove non-finite values, 
    % length(pj) = m + 1 in Embedded MATLAB.
    for i = 1:eml_index_minus(i0,1)
        num(j,i) = 0;
    end
    for i = i0:numcols
        num(j,i) = pj(eml_index_plus(eml_index_minus(i,i0),1));
    end
end
