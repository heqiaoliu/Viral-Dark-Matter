classdef MCOS < helpUtils.classWrapper.base
    properties (SetAccess=protected, GetAccess=protected)
        metaClass = [];
        packagedName = '';
        classDir = '';
        classHasNoAtDir = false;
    end
    
    methods
        function [helpText, needsHotlinking, shadowedClassInfo, shadowedWrapper] = getShadowedHelp(cw, elementName, hotLinkCommand)
            helpText = '';
            needsHotlinking = false;
            shadowedClassInfo = [];
            shadowedWrapper = [];
            cw.loadClass;
            if ~isempty(cw.metaClass)
                supers = cw.metaClass.SuperClasses;
                for i = 1:length(supers)
                    super = supers{i};
                    superMethod = helpUtils.getMethod(super, elementName);
                    if ~isempty(superMethod)
                        definingClass = superMethod.DefiningClass;
                        [shadowedClassInfo, definingClassWrapper] = cw.getSuperClassInfo(definingClass, superMethod.Abstract, elementName);
                        % hasHelp is recursive, so superclass shadowed classes will be found
                        if ~isempty(shadowedClassInfo)
                            [helpText, needsHotlinking] = shadowedClassInfo.innerGetHelp(hotLinkCommand);
                            if ~isempty(helpText)
                                shadowedWrapper = definingClassWrapper;
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
    
    methods (Access=protected)
        function cw = MCOS(packagedName, className, classDir)
            cw.packagedName = packagedName;
            cw.className = className;
            cw.classDir = classDir;
            if ~isempty(regexp(cw.classDir, ['@' cw.className '$'], 'once'))
                cw.classPaths = {cw.classDir};
            end
        end
        
        function loadClass(cw)
            if isempty(cw.metaClass)
                try %#ok<TRYNC> probably an error parsing the class file
                    cw.metaClass = meta.class.fromName(cw.packagedName);
                end
            end
        end
        
        function [classInfo, definingClassWrapper] = getSuperClassInfo(cw, definingClass, isAbstractMethod, elementName)
            definingClassWrapper = helpUtils.classWrapper.superMCOS(definingClass, cw.subClassPath, cw.subClassPackageName, isAbstractMethod);
            classInfo = definingClassWrapper.getElement(elementName, false);
            if ~isempty(classInfo)
                classInfo.className = cw.className;
                if cw.classHasNoAtDir
                    classInfo.insertClassName;
                end
                definingClassWrapper.classHasNoAtDir = cw.classHasNoAtDir;
                classInfo.superWrapper = definingClassWrapper;
            end
        end
        
        function classInfo = innerGetLocalMethod(cw, methodName, isAbstract)
            classInfo = [];
            if ~isempty(cw.classDir)
                classMFile = fullfile(cw.classDir, [cw.className '.m']);
                if exist(classMFile, 'file')
                    if ~isAbstract && ~any(strcmp(which('-subfun',classMFile), [cw.className '.' methodName]))
                        return;
                    end
                elseif ~exist(fullfile(cw.classDir, [cw.className '.p']), 'file')
                    return;
                end
                if isAbstract
                    classInfo = helpUtils.classInformation.abstractMethod(cw, cw.className, cw.classDir, cw.subClassPath, methodName, cw.subClassPackageName);
                else
                    classInfo = helpUtils.classInformation.localMethod(cw, cw.className, cw.classDir, cw.subClassPath, methodName, cw.subClassPackageName);
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2009/12/14 22:25:19 $
