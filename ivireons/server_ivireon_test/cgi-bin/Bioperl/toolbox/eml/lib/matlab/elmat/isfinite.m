function b = isfinite(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'numeric') || ischar(x) || islogical(x), ...
    ['Function ''isfinite'' is not defined for values of class ''' class(x) '''.']);
b = ~isinf(x) & ~isnan(x);

