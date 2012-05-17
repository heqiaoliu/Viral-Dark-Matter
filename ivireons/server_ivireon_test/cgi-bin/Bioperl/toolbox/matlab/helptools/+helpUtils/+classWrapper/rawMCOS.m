classdef rawMCOS < helpUtils.classWrapper.MCOS & helpUtils.classWrapper.raw
    properties (SetAccess=private, GetAccess=private)
        packageName = '';
    end

    methods
        function cw = rawMCOS(className, packagePath, packageName, classHasNoAtDir, isUnspecifiedConstructor, implementor)
            packagedName = helpUtils.makePackagedName(packageName, className);
            if classHasNoAtDir
                classDir = packagePath;
            else
                classDir = fullfile(packagePath, ['@', className]);
            end
            cw = cw@helpUtils.classWrapper.MCOS(packagedName, className, classDir);
            cw.classHasNoAtDir = classHasNoAtDir;
            cw.isUnspecifiedConstructor = isUnspecifiedConstructor;
            cw.implementor = implementor;
            cw.packageName = packageName;
            cw.subClassPath = classDir;
            cw.subClassPackageName = cw.packageName;
        end

        function classInfo = getConstructor(cw, justChecking)
            if cw.isUnspecifiedConstructor
                classInfo = helpUtils.classInformation.fullConstructor(cw, cw.packageName, cw.className, cw.subClassPath, cw.classHasNoAtDir, true, justChecking);
            else
                classInfo = helpUtils.classInformation.localConstructor(cw.packageName, cw.className, cw.subClassPath, justChecking);
            end
        end

        function classInfo = getElement(cw, elementName, justChecking)
            if cw.classHasNoAtDir
                classInfo = cw.getLocalElement(elementName, justChecking);
            else
                classInfo = cw.getElement@helpUtils.classWrapper.MCOS(elementName, justChecking);
            end
            if ~isempty(classInfo)
                classInfo.setImplementor(cw.implementor);
            end
        end
        
        function classInfo = getMethod(cw, classMethod)
            cw.loadClass;
            elementName = classMethod.Name;

            classInfo = cw.getFileMethod(elementName);
            if isempty(classInfo)
                classInfo = cw.innerGetMethod(classMethod);
            else
                cw.setAccessibleMethod(classInfo, classMethod);
            end
        end

        function classInfo = getProperty(cw, classProperty, justChecking)
            cw.loadClass;
            elementName = classProperty.Name;

            definingClass = classProperty.DefiningClass;
            if definingClass == cw.metaClass || justChecking
                classInfo = helpUtils.classInformation.propertyMCOS(cw.className, cw.subClassPath, elementName, cw.subClassPackageName);
            else
                definingClassWrapper = helpUtils.classWrapper.superMCOS(definingClass, cw.subClassPath, cw.subClassPackageName);
                classInfo = definingClassWrapper.getProperty(elementName);
                classInfo.className = cw.className;
                classInfo.superWrapper = definingClassWrapper;
            end
            classInfo.isAccessible = ~cw.metaClass.Hidden && helpUtils.isAccessibleProperty(classProperty, cw.implementor);
        end
    end

    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, justChecking)
            classInfo = [];
            cw.loadClass;
            if ~isempty(cw.metaClass)
                classMethod = helpUtils.getMethod(cw.metaClass, elementName);

                if ~isempty(classMethod)
                    classInfo = cw.innerGetMethod(classMethod);
                else
                    classProperty = helpUtils.getProperty(cw.metaClass, elementName);

                    if ~isempty(classProperty)
                        classInfo = cw.getProperty(classProperty, justChecking);
                    end
                end
            end
        end
    end

    methods (Access=private)
        function classInfo = innerGetMethod(cw, classMethod)
            elementName = classMethod.Name;
            definingClass = classMethod.DefiningClass;
            if definingClass == cw.metaClass
                classInfo = innerGetLocalMethod(cw, elementName, classMethod.Abstract);
            else
                classInfo = cw.getSuperClassInfo(definingClass, classMethod.Abstract, elementName);
            end
            if ~isempty(classInfo)
                cw.setAccessibleMethod(classInfo, classMethod);
            end
        end

        function setAccessibleMethod(cw, classInfo, classMethod)
            classInfo.isAccessible = ~cw.metaClass.Hidden && helpUtils.isAccessibleMethod(classMethod, cw.implementor);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.13 $  $Date: 2009/12/14 22:25:22 $
