function y = eml_size_prod(x,i,j)
%Embedded MATLAB Private Function

%    y = prod(cast(sz(i:j),eml_index_class), where sz = size(x).  The
%    arithmetic is performed in eml_index_class with no saturation.  The
%    input i defaults to 1, and j defaults to ndims(x).

%    Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
if nargin < 3
    j = cast(ndims(x),eml_index_class);
    if nargin < 2
        i = ones(eml_index_class);
    end
end
eml_prefer_const(i,j);
y = ones(eml_index_class);
for k = cast(i,eml_index_class):cast(j,eml_index_class)
    y = eml_index_times(y,size(x,k));
end