function b = isAccessibleMethodName(packageName, className, methodName, implementor)
    try
        packagedName = helpUtils.makePackagedName(packageName, className);
        metaClass = meta.class.fromName(packagedName);
        if isempty(metaClass)
            b = true;
        elseif metaClass.Hidden
            b = false;
        else
            classMethod = helpUtils.getMethod(metaClass, methodName);
            b = helpUtils.isAccessibleMethod(classMethod, implementor);
        end
    catch e %#ok<NASGU>
        % probably an error parsing the class file
        b = false;
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/06/24 17:13:24 $
