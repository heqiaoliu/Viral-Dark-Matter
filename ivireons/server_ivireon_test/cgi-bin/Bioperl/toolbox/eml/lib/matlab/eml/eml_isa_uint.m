function p = eml_isa_uint(x)
%Embedded MATLAB Private Function

%   Returns true if X is an unsigned integer.

%   Copyright 2005-2007 The MathWorks, Inc.
%#eml

p = isa(x,'uint32') || isa(x,'uint16') || isa(x,'uint8') || isa(x,'uint64');
