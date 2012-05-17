function y = isscaleddouble(x)
% Embedded MATLAB Library function.

%ISSCALEDDOUBLE  True for FI object with "scaleddouble" as the datatype input.
%   ISSCALEDDOUBLE(X) returns 1 if X is a FI object with datatype == scaleddouble;
%              and 0 if X is a FI object with datatype != scaleddouble.
%
%   Examples:
%     x = fi(pi, 'datatype','scaleddouble');
%     isscaleddouble(x)
%
%   Copyright 2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:42:56 $

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

T = eml_typeof(x);
y = eml_const(strcmpi(get(T, 'DataType'), 'ScaledDouble')); 

%----------------------------------------------------
