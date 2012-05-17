classdef fileConstructor < helpUtils.classInformation.constructor
    properties (SetAccess=protected, GetAccess=protected)
        noAtDir = true;
        classPath = '';
        classWrapper = [];
    end
    
    methods
        function ci = fileConstructor(packageName, className, classPath, fullPath, noAtDir, justChecking)
            ci@helpUtils.classInformation.constructor(packageName, className, fullPath, fullPath, justChecking);
            ci.classPath = classPath;
            ci.noAtDir = noAtDir;
        end
        
        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            ci.prepareForSecondaryHelp;
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
        end
        
        function b = hasHelp(ci)
            b = ci.checkHelp;
            if ~b
                ci.prepareForSecondaryHelp;
                b = ci.checkHelp;
            end
        end
        
        function constructorInfo = getConstructorInfo(ci, useClassHelp)
            constructorInfo = [];
            if useClassHelp || ci.checkHelp
                % only concerned with constructor info if there is both class and constructor help
                constructorInfo = helpUtils.classInformation.localConstructor(ci.packageName, ci.className, ci.classPath, false);
                if ~useClassHelp && ~constructorInfo.hasHelp;
                    constructorInfo = [];                    
                end
            end
        end
        
        function methodInfo = getMethodInfo(ci, classMethod, inheritHelp)
            ci.createWrapper;
            methodInfo = ci.classWrapper.getMethod(classMethod);
            if ~isempty(methodInfo)
                methodInfo.inheritHelp = inheritHelp;
            end
        end
        
        function propertyInfo = getPropertyInfo(ci, classProperty)
            ci.createWrapper;
            propertyInfo = ci.classWrapper.getProperty(classProperty, false);
        end
    end
    
    methods (Access=private)
        function prepareForSecondaryHelp(ci)
            % did not find help for the constructor, see if there is help for the localFunction constructor
            ci.definition = regexprep(ci.whichTopic, [ci.className '(\.[mp])?$'] ,[ci.className filemarker ci.className]);
        end

        function createWrapper(ci)
            if isempty(ci.classWrapper)
                if ci.noAtDir
                    packagePath = ci.classPath;
                else
                    packagePath = fileparts(ci.classPath);
                end
                ci.classWrapper = helpUtils.classWrapper.rawMCOS(ci.className, packagePath, ci.packageName, ci.noAtDir, false, true);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2009/12/14 22:25:03 $
