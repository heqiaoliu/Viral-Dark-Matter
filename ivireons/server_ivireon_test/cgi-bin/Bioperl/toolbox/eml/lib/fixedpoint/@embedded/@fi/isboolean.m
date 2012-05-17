function y = isboolean(x)
% Embedded MATLAB Library function.

%ISBOOLEAN  True for FI object with "boolean" as the datatype input.
%   ISBOOLEAN(X) returns 1 if X is a FI object with datatype == boolean;
%              and 0 if X is a FI object with datatype != boolean.
%
%   Examples:
%     x = fi(pi, 'datatype','boolean');
%     isboolean(x)
%
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

T = eml_typeof(x);
y = eml_const(strcmpi(get(T, 'DataType'), 'Boolean')); 
