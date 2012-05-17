function bool = eml_is_integer_class(cls)
%Embedded MATLAB Private Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if ischar(cls)
    bool = strcmp(cls,'int32') || strcmp(cls,'uint32') || ...
        strcmp(cls,'int16') || strcmp(cls,'uint16') || ...
        strcmp(cls,'int8') || strcmp(cls,'uint8') || ...
        strcmp(cls,'int64') || strcmp(cls,'uint64');
else
    bool = false;
end
