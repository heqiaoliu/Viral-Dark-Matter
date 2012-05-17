function outcls = eml_unsigned_class(incls)
%Embedded MATLAB Private Function

%   Returns the unsigned integer class with the same size as incls.

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_must_inline;
switch incls
    case {'int32','uint32'}
        outcls = 'uint32';
    case {'int16','uint16'}
        outcls = 'uint16';
    case {'int8','uint8'}
        outcls = 'uint8';
    case {'int64','uint64'}
        outcls = 'uint64';
    otherwise
        eml_assert(false,'Not a recognized integer class.');
end

