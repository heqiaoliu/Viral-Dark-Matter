function packagedName = makePackagedName(packageName, className)
    if isempty(packageName)
        packagedName = className;
    else
        packagedName = [packageName '.' className];
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2007/12/14 14:53:39 $
