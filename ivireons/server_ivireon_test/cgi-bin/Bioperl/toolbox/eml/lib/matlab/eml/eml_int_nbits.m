function n = eml_int_nbits(cls)
%Embedded MATLAB Private Function

%   Returns the number of bits in the integer class CLS.

%   Copyright 2005-2007 The MathWorks, Inc.
%#eml

switch cls
    case {'uint32','int32'}
        n = uint8(32);
    case {'uint16','int16'}
        n = uint8(16);
    case {'uint8','int8'}
        n = uint8(8);
    case {'uint64','int64'}
        n = uint8(64);
    otherwise
        eml_assert(false,'Not a recognized integer class.');
end
