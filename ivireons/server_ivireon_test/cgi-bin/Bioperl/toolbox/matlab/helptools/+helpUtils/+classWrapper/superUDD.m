classdef superUDD < helpUtils.classWrapper.UDD & helpUtils.classWrapper.super
    methods
        function cw = superUDD(schemaClass, subClassPath, subClassPackageName)
            cw.subClassPackageName = subClassPackageName;
            cw.subClassPath = subClassPath;
            cw.schemaClass = schemaClass;
            cw.className = schemaClass.Name;
            cw.packageHandle = schemaClass.Package;
            allPackageDirs = helpUtils.hashedDirInfo(['@' cw.packageHandle.Name]);
            packagePaths = {allPackageDirs.path};
            cw.classPaths = strcat(packagePaths, ['/@' cw.className]);
        end
        
        function classInfo = getElement(cw, elementName, justChecking)
            if strcmpi(cw.className, elementName)
                classInfo = cw.getSuperElement(elementName);
            else
                classInfo = cw.getElement@helpUtils.classWrapper.UDD(elementName, justChecking);
            end
        end
        
        function b = hasClassHelp(cw)
            classInfo = cw.getClassHelpFile;
            if isempty(classInfo)
                b = false;
            else
                b = classInfo.checkHelp;
            end
        end

        function classInfo = getPropertyHelpFile(cw)
            classInfo = cw.getFileMethod('schema');
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, justChecking) %#ok<INUSD>
            classInfo = cw.getSuperElement(elementName);
        end

        function b = isConstructor(cw, methodName) %#ok<INUSD,MANU>
            b = false;
        end

        function classInfo = getClassHelpFile(cw)
            classInfo = cw.getFileMethod(cw.className);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2009/12/14 22:25:25 $
