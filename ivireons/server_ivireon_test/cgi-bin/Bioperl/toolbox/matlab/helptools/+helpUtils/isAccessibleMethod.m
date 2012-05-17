function b = isAccessibleMethod(classMethod, implementor)
    if classMethod.Hidden
        b = false;
    else
        if implementor
            b = ~strcmp(classMethod.Access, 'private');
        else
            b = strcmp(classMethod.Access, 'public');
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/06/24 17:13:23 $
