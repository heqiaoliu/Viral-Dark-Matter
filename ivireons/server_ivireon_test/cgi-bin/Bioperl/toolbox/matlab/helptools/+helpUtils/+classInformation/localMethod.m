classdef localMethod < helpUtils.classInformation.method
    methods
        function ci = localMethod(classWrapper, className, basePath, derivedPath, methodName, packageName)
            fileMethod = [className filemarker methodName];
            definition = fullfile(basePath, fileMethod);
            minimalPath = fullfile(derivedPath, fileMethod);
            whichTopic = fullfile(derivedPath, [className '.m']);
            ci@helpUtils.classInformation.method(classWrapper, packageName, className, methodName, definition, minimalPath, whichTopic);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/14 22:25:09 $
