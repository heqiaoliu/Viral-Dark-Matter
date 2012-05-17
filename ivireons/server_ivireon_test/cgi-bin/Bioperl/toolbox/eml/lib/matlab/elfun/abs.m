function y = abs(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'numeric') || ischar(x) || islogical(x), ...
    ['Function ''abs'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isa(x,'float') || isreal(x), 'Complex integers are not supported.');
if ischar(x) || islogical(x)
    y = eml.nullcopy(zeros(size(x)));
else
    y = eml.nullcopy(zeros(size(x),class(x)));
end
for k = 1:eml_numel(x)
    y(k) = eml_scalar_abs(x(k));
end
