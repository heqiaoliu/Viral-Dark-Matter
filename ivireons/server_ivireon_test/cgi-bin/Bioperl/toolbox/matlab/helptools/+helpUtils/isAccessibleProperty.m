function b = isAccessibleProperty(classProperty, implementor)
    if classProperty.Hidden
        b = false;
    else
        if implementor
            b = ~strcmp(classProperty.GetAccess, 'private') || ~strcmp(classProperty.SetAccess, 'private');
        else
            b = strcmp(classProperty.GetAccess, 'public') || strcmp(classProperty.SetAccess, 'public');
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 02:10:35 $
