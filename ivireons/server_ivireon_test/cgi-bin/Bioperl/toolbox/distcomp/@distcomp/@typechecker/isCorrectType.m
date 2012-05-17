function isok = isCorrectType(datatype, value)
; %#ok Undocumented
% Returns true if the value is of the correct data type.

%   Copyright 2007-2008 The MathWorks, Inc.

obj = distcomp.typechecker.pGetInstance();
prop = obj.pTypeToPropertyName(datatype);

% Try to set the property to the specified value and let UDD handle the error
% checking.  Remember to reset the value of obj.(prop) to the original, default
% value.
oldvalue = obj.(prop);
try
    obj.(prop) = value;
    obj.(prop) = oldvalue;
    isok = true;
catch err %#ok<NASGU>
    isok = false;
end
