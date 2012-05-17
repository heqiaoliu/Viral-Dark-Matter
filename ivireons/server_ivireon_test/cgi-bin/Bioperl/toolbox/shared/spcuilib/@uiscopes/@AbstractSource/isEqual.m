function b = isEqual(this, hExtInst)
%ISEQUAL  True if the object is Equal

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:08:43 $

if strcmp(this.Register.Type, hExtInst.Register.Type)
    if strcmp(this.Register.Name, hExtInst.Register.Name)
        b = true;
    else
        b = false;
    end
else
    b = false;
end

% [EOF]
