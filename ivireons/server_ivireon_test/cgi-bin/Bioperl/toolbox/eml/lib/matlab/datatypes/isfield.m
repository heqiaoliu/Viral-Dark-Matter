function p = isfield(s,fieldname)
%Embedded MATLAB Library Function

%   Limitations:  Cell input for second argument is not supported.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

for j = eml.unroll(0:eml_numfields(s)-1)
    if strcmp(eml_getfieldname(s,j),fieldname)
        p = true;
        return
    end
end
p = false;
