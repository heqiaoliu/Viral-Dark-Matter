classdef base < handle
    properties (SetAccess=protected, GetAccess=protected)
        className = '';
        classPaths = {};
        subClassPath = '';
        subClassPackageName = '';
    end
    
    methods (Abstract, Access=protected)
        classInfo = getLocalElement(cw, elementName, justChecking);
    end
    
    
    methods
        function classInfo = getClassInformation(cw, elementName, justChecking)
            if cw.isConstructor(elementName)
                classInfo = cw.getConstructor(justChecking);
            else
                classInfo = cw.getElement(elementName, justChecking);
            end
        end

        function classInfo = getElement(cw, elementName, justChecking)
            classInfo = cw.getFileMethod(elementName);
            if isempty(classInfo)
                classInfo = cw.getLocalElement(elementName, justChecking);
            end
        end
    end    

    methods (Access=protected)
        function classInfo = getFileMethod(cw, methodName)
            classInfo = [];
            for j=1:length(cw.classPaths)
                allClassInfo = helpUtils.hashedDirInfo(cw.classPaths{j});
                if isempty(allClassInfo)
                    cw.classPaths{j} = fileparts(cw.classPaths{j});
                else
                    for i = 1:length(allClassInfo)
                        classDirInfo = allClassInfo(i);
                        [fixedName, foundTarget] = helpUtils.extractFile(classDirInfo, methodName);
                        if foundTarget
                            classInfo = helpUtils.classInformation.fileMethod(cw, cw.className, classDirInfo.path, cw.subClassPath, fixedName, cw.subClassPackageName);
                            return;
                        end
                    end
                end
            end
        end
        
        function b = isConstructor(cw, methodName)
            b = strcmpi(cw.className, methodName);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $  $Date: 2009/12/14 22:25:21 $
