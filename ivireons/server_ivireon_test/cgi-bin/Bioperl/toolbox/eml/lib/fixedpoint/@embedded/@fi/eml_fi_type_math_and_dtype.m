function [t f dtype] = eml_fi_type_math_and_dtype(a)
%EML_FI_TYPE_MATH_AND_DTYPE Internal use only function

%   [T F DTYPE] = EML_FI_TYPE_MATH_AND_DTYPE(A) returns the NumericType,
%   Fimath and DataType of fi object A in T, F and DTYPE, respectively.

% Copyright 2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2008/02/20 01:05:15 $

eml_transient;
t = eml_typeof(a);
f = eml_fimath(a);
dtype = eml_fi_getDType(a);
