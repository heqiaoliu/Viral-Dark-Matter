classdef fullConstructor < helpUtils.classInformation.fileConstructor
    properties (SetAccess=private, GetAccess=private)
        isUnspecified = false;
    end

    methods
        function ci = fullConstructor(classWrapper, packageName, className, basePath, noAtDir, isUnspecified, justChecking)
            ci@helpUtils.classInformation.fileConstructor(packageName, className, basePath, fullfile(basePath, [className '.m']), noAtDir, justChecking);
            ci.classWrapper = classWrapper;
            ci.isUnspecified = isUnspecified;
        end

        function b = isClass(ci)
            if ci.noAtDir
                b = ci.isMCOSClass;
            else
                b = ci.isUnspecified;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2009/12/14 22:25:06 $
