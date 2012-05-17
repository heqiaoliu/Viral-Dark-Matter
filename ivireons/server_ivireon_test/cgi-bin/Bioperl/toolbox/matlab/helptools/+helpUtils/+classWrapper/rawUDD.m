classdef rawUDD < helpUtils.classWrapper.UDD & helpUtils.classWrapper.raw
    methods
        function cw = rawUDD(className, packagePath, packageHandle, isUnspecifiedConstructor, implementor)
            cw.isUnspecifiedConstructor = isUnspecifiedConstructor;
            cw.implementor = implementor;
            cw.className = className;
            cw.packageHandle = packageHandle;
            cw.subClassPath = fullfile(packagePath, ['@', className]);
            cw.classPaths = {cw.subClassPath};
            cw.subClassPackageName = packageHandle.Name;
        end

        function classInfo = getConstructor(cw, ~)
            classInfo = helpUtils.classInformation.fullConstructor(cw, cw.packageHandle.Name, cw.className, cw.subClassPath, false, cw.isUnspecifiedConstructor, true);
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, justChecking)
            classInfo = [];
            classMethods = methods([cw.packageHandle.Name '.' cw.className]);
            methodIndex = strcmpi(classMethods, elementName);
            if any(methodIndex)
                elementName = classMethods{methodIndex};
                if justChecking
                    classInfo = helpUtils.classInformation.fileMethod(cw, cw.className, cw.subClassPath, cw.subClassPath, elementName, cw.subClassPackageName);
                else
                    cw.loadClass;
                    classInfo = cw.getSuperElement(elementName);
                    if ~isempty(classInfo)
                        classInfo.className = cw.className;
                    end
                end
            elseif cw.implementor
                cw.loadClass;
                if ~isempty(cw.schemaClass)
                    for classProperty = cw.schemaClass.Properties'
                        if strcmpi(classProperty.Name, elementName)
                            if strcmp(classProperty.Visible, 'on')
                                if strcmp(classProperty.AccessFlags.PublicSet, 'on') || strcmp(classProperty.AccessFlags.PublicGet, 'on')
                                    classInfo = helpUtils.classInformation.propertyUDD(cw, cw.className, cw.subClassPath, classProperty.Name, cw.subClassPackageName);
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    methods (Access=private)
        function loadClass(cw)
            if isempty(cw.schemaClass)
                try
                    cw.schemaClass = cw.packageHandle.findclass(cw.className);
                catch e %#ok<NASGU>
                    % probably an error parsing the class file
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2009/12/14 22:25:23 $
