function n = eml_prodsize_except_dim(x,dim)
%Embedded MATLAB Private Function

%   Returns 
%   n = size(x,1)*size(x,2)*...*size(x,dim-1)*size(x,dim+1)*...

%   Copyright 2009 The MathWorks, Inc.
%#eml

eml_prefer_const(dim);
sx = size(x);
sx(dim) = 1;
n = eml_numel(zeros(sx));
