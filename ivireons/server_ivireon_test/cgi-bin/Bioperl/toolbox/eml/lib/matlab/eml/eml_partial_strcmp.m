function p = eml_partial_strcmp(mstrstr,userstr)
%Embedded MATLAB Private Function

%   Partial-matching strcmp.  The return value p is true if and only if
%   numel(userstr) <= numel(mstrstr) and userstr(k) == mstrstr(k) for
%   k = 1:numel(userstr).  This is a case-sensitive comparison, so
%   eml_tolower should be used on the input arguments if a case-insensitive
%   match is desired.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_prefer_const(mstrstr,userstr);
nm = eml_numel(mstrstr);
nu = eml_numel(userstr);
if nu > nm
    p = false;
else
    for k = 1:nu
        if mstrstr(k) ~= userstr(k)
            p = false;
            return
        end
    end
    p = true;
end
