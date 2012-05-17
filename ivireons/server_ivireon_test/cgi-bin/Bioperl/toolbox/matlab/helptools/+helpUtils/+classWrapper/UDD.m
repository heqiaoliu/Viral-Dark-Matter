classdef UDD < helpUtils.classWrapper.base
    properties (SetAccess=protected, GetAccess=protected)
        packageHandle;
        schemaClass;
    end

    methods (Access=protected)
        function classInfo = getSuperElement(cw, elementName)
            classInfo = [];
            if ~isempty(cw.schemaClass)
                supers = cw.schemaClass.SuperClasses';
                for super = supers
                    wrappedSuper = helpUtils.classWrapper.superUDD(super, cw.subClassPath, cw.subClassPackageName);
    
                    classInfo = wrappedSuper.getElement(elementName, false);
    
                    if ~isempty(classInfo)
                        if isempty(classInfo.superWrapper)
                            classInfo.superWrapper = wrappedSuper;
                        end
                        return;
                    end
                end
            end
        end
    end
    
    methods
        function [helpText superClassInfo] = getSuperPropertyHelp(cw, propertyName)
            helpText = '';
            superClassInfo = [];
            if ~isempty(cw.schemaClass)
                supers = cw.schemaClass.SuperClasses';
                for super = supers
                    wrappedSuper = helpUtils.classWrapper.superUDD(super, cw.subClassPath, cw.subClassPackageName);
                    
                    classdefInfo = wrappedSuper.getPropertyHelpFile;
                    superProperty = helpUtils.classInformation.propertyUDD(wrappedSuper, wrappedSuper.className, fileparts(classdefInfo.definition), propertyName, cw.subClassPackageName);

                    [helpText superClassInfo] = superProperty.getSuperHelp;
                    
                    if ~isempty(helpText)
                        if isempty(superClassInfo.superWrapper)
                            superClassInfo.superWrapper = wrappedSuper;
                        end
                        return;
                    end
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2009/12/14 22:25:20 $
