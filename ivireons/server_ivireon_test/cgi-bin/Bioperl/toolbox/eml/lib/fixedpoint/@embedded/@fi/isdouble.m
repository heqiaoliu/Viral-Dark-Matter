function y = isdouble(x)
% Embedded MATLAB Library function.

%ISDOUBLE  True for FI object with "double" as the datatype input.
%   ISDOUBLE(X) returns 1 if X is a FI object with datatype == double;
%              and 0 if X is a FI object with datatype != double.
%
%   Examples:
%     x = fi(pi, 'datatype','double');
%     isdouble(x)
%
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

T = eml_typeof(x);
y = eml_const(strcmpi(get(T, 'DataType'), 'Double')); 
    
      
