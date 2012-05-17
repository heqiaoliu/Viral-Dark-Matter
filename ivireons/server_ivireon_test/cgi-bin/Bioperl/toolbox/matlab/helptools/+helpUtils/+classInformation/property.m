classdef property < helpUtils.classInformation.classElement
    properties (SetAccess=private, GetAccess=protected)
        foundProperty = false;
    end

    methods
        function ci = property(className, classPath, propertyName, packageName)
            definition = fullfile(classPath, [className filemarker propertyName]);
            whichTopic = fullfile(classPath, [className '.m']);
            ci@helpUtils.classInformation.classElement(packageName, className, propertyName, definition, definition, whichTopic);
            ci.isProperty = true;
        end

        function topic = fullTopic(ci)
            topic = [helpUtils.makePackagedName(ci.packageName, ci.className) '/' ci.element];
        end
    end
    
    methods (Access=protected)
        function helpText = getPropertyHelp(ci, helpFile)
            helpText = helpUtils.callHelpFunction(@ci.getHelpTextFromFile, helpFile);
        end
    end
    
    methods (Access=private)
        function helpText = getHelpTextFromFile(ci, fullPath)
            helpText = '';
            if ~ci.foundProperty
                classFile = fileread(fullPath);
                allPropertyHelps = ci.getAllPropertyHelps(classFile);
                allPropertyHelps(~strcmp(ci.element, {allPropertyHelps.property})) = [];
                for propertyHelp = allPropertyHelps
                    ci.foundProperty = true;
                    [helpText, prependName] = ci.extractHelpText(propertyHelp);
                    if ~isempty(helpText)
                        helpText = regexprep(helpText, '^\s*%', ' ', 'lineanchors');
                        helpText = regexprep(helpText, '\r', '');
                        if prependName
                            helpText = [' ' ci.element ' -' helpText]; %#ok<AGROW>
                        end
                        return;
                    end
                end
            end
        end
    end
    
    methods (Static, Abstract, Access=protected)
        allPropertyHelps = getAllPropertyHelps(classFile)        
        [helpText, prependName] = extractHelpText(propertyHelp)
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $  $Date: 2009/12/14 22:25:15 $
