function x = swapbytes(x)
%Embedded MATLAB Library Function

%   Limitations:
%   Inheritance of the class of the input to SWAPBYTES in an Embedded
%   MATLAB Function block is only supported when class(x) is 'double'.  For
%   non-double inputs, the input port data types must be specified, not
%   inherited. 

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments');
if isa(x,'uint8') || isa(x,'int8')
    return
end
for k = 1:eml_numel(x)
    x(k) = typecast(fliplr(typecast(x(k),'uint8')),class(x));
end
