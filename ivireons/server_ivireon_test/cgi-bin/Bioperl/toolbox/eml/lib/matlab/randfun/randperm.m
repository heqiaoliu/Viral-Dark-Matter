function p = randperm(n)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1, 'Not enough input arguments.');
eml_prefer_const(n);
p = rand(1,n);
idx = eml_sort_idx(p,'a');
p(:) = idx(:);
