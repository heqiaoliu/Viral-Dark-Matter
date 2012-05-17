classdef fileMethod < helpUtils.classInformation.method
    properties (SetAccess=private, GetAccess=private)
        implementor = [];
    end
    
    methods
        function ci = fileMethod(classWrapper, className, basePath, derivedPath, methodName, packageName)
            fileName = [methodName '.m'];
            definition = fullfile(basePath, fileName);
            whichTopic = fullfile(derivedPath, fileName);
            ci@helpUtils.classInformation.method(classWrapper, packageName, className, methodName, definition, whichTopic, whichTopic);
        end

        function insertClassName(ci)
            ci.minimalPath = regexprep(ci.minimalPath, '(.*[\\/])(.*)', ['$1' ci.className filemarker '$2']);
        end
        
        function setImplementor(ci, implementor)
            ci.implementor = implementor;
            ci.isAccessible = helpUtils.isAccessibleMethodName(ci.packageName, ci.className, ci.element, ci.implementor);
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            % Did not find help for a file function, see if there is help for a local function.
            % This is for an anomalous case, in which a method is defined as both a file in an @-dir
            % and as a local function in a classdef, in which the local function will trump the file.
            ci.definition = regexprep(ci.definition, '@(?<className>\w++)[\\/](?<methodName>\w*)(\.[mp])?$', ['@$<className>/$<className>' filemarker '$<methodName>']);
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
            if isempty(helpText)
                [helpText, needsHotlinking] = ci.getSecondaryHelp@helpUtils.classInformation.method(hotLinkCommand);
            end            
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/14 22:25:04 $
