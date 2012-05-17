function bool = eml_is_float_class(cls)
%Embedded MATLAB Private Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if ischar(cls)
    bool = strcmp(cls,'double') || strcmp(cls,'single');
else
    bool = false;
end

