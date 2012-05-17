function y = isfixed(T)
%ISFIXED Determine whether numerictype object is fixed point or integer
%    ISFIXED(T) returns 1 when the DataType property of numerictype object T
%    is 'Fixed', and 0 otherwise.
%
% Copyright 2008 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.1 $

eml.extrinsic('strcmpi');

eml_assert(nargin == 1, 'error', 'Not the correct number of input arguments.');

y = eml_const(strcmpi(get(T, 'DataType'), 'Fixed'));

