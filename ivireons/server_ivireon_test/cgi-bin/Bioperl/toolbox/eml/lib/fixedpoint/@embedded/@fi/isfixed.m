function y = isfixed(x)
% Embedded MATLAB Library function.

%ISFIXED  True for FI object with "fixed" as the datatype input.
%   ISFIXED(X) returns 1 if X is a FI object with datatype == fixed;
%              and 0 if X is a FI object with datatype != fixed.
%
%   Examples:
%     x = fi(pi, 'datatype','fixed');
%     isfixed(x)
%
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

T = eml_typeof(x);
y = eml_const(strcmpi(get(T, 'DataType'), 'Fixed'));

