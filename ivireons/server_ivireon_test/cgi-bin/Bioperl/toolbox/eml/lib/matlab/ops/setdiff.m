function [c,ia] = setdiff(varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1. When 'rows' is not specified:
%       Inputs must be row vectors. If a vector is variable-size, its first
%       dimension must have a fixed length of 1. The input [] is not
%       supported. Use a 1-by-0 input (e.g., zeros(1,0)) to represent the
%       empty set.  Empty outputs are always row vectors, 1-by-0, never
%       0-by-0.
%   2. When 'rows' is specified:
%       Outputs IA and IB are always column vectors, 0-by-1 if empty, never
%       0-by-0, even if the output C is 0-by-0.
%   3. Inputs must already be sorted in ascending order. The first output 
%       will always be sorted in ascending order.
%   4. Complex inputs must be 'single' or 'double'.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
if nargout == 2
    [c,ia] = eml_setop('setdiff',varargin{:});
else
    c = eml_setop('setdiff',varargin{:});
end