function y = eml_index_prod(x,i,j)
%Embedded MATLAB Private Function

%    y = prod(cast(x(i:j),eml_index_class) performed in eml_index_class
%    with no saturation.  The input i defaults to 1, and j defaults to 
%    numel(x).

%    Copyright 2005-2008 The MathWorks, Inc.
%#eml

if nargin < 3
    j = cast(eml_numel(x),eml_index_class);
    if nargin < 2
        i = ones(eml_index_class);
    end
end
eml_prefer_const(i,j);
y = ones(eml_index_class);
for k = cast(i,eml_index_class):cast(j,eml_index_class)
    y = eml_index_times(y,x(k));
end