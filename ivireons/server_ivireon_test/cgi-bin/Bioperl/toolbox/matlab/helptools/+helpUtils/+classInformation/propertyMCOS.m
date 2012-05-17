classdef propertyMCOS < helpUtils.classInformation.property
    methods
        function ci = propertyMCOS(className, classPath, propertyName, packageName)
            ci = ci@helpUtils.classInformation.property(className, classPath, propertyName, packageName);
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            needsHotlinking = true;
            helpText = getPropertyHelp(ci, ci.whichTopic);
        end 
    end
    
    methods (Static, Access=protected)
        function allPropertyHelps = getAllPropertyHelps(classFile)
            propertySections = regexp(classFile, '^\s*properties\>.*(?<inside>.*\n)*?^\s*end\>', 'names', 'dotexceptnewline', 'lineanchors');
            % cast the input to regexp to char so empty will do the right thing
            allPropertyHelps = regexp(char([propertySections.inside]), '^(?<preHelp>[ \t]*+%.*+\n)*[ \t]*+(?<property>\w++)[^\n%]*+(?<postHelp>%.*+\n)?', 'names', 'dotexceptnewline', 'lineanchors');
        end
        
        function [helpText, prependName] = extractHelpText(propertyHelp)
            prependName = false;
            if ~isempty(propertyHelp.preHelp)
                helpText = propertyHelp.preHelp;
            else
                prependName = true;
                helpText = propertyHelp.postHelp;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/05/18 20:48:54 $
