function [isvalid,errmsg,msgid] = validate(h,specs)
%VALIDATE   Perform algorithm specific spec. validation.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:16:34 $

% Populate defaults
isvalid = true;
errmsg = '';
msgid = '';

vso = validspecobj(h);

% Handle the cell of strings, i.e. multiple valid specification objects.
if iscellstr(vso)
    for indx = 1:length(vso)
        if isa(specs, vso{indx})
            isvalid(indx) = true;
        else
            isvalid(indx) = false;
        end
    end
    isvalid = any(isvalid);
else
    isvalid = isa(specs, vso);
end

if ~isvalid
    errmsg = ['Specifications must be given in a FSPECS object of class ',validspecobj(h),'.'];
    msgid = generatemsgid('invalidSpec');
end

% [EOF]
