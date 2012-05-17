function y = issingle(x)
% Embedded MATLAB Library function.

%ISSINGLE  True for FI object with "single" as the datatype input.
%   ISSINGLE(X) returns 1 if X is a FI object with datatype == single;
%              and 0 if X is a FI object with datatype != single.
%
%   Examples:
%     x = fi(pi, 'datatype','single');
%     issingle(x)
%
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

T = eml_typeof(x);
y = eml_const(strcmpi(get(T, 'DataType'), 'Single')); 
