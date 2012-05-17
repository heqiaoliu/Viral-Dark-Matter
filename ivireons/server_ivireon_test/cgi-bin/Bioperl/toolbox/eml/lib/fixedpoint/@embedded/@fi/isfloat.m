function y = isfloat(x)
% Embedded MATLAB Library function.

%ISFLOAT  True for FI object with "double" or "single" as the datatype input.
%   ISFLOAT(X) returns 1 if X is a FI object with datatype == double or single;
%              and 0 if X is a FI object with datatype != double nor single.
%
%   Examples:
%     x = fi(pi, 'datatype','double');
%     isfloat(x)
%
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

T = eml_typeof(x);
y = eml_const(strcmpi(get(T, 'DataType'), 'Single')) ||  eml_const(strcmpi(get(T, 'DataType'), 'Double')); 
    
  
  
