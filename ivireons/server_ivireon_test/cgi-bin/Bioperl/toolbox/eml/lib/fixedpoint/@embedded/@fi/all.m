function y = all(x,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isnumeric(x) || ischar(x) || islogical(x), ...
    ['Function ''all'' is not defined for values of class ''' class(x) '''.']);
if nargin < 2
    y = eml_all_or_any('all',x);
else
    eml_prefer_const(dim);
    y = eml_all_or_any('all',x,double(dim));
end
