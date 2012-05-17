classdef method < helpUtils.classInformation.classElement
    properties (SetAccess=private, GetAccess=private)
        classWrapper;
    end
    
    properties (SetAccess=public, GetAccess=private)
        inheritHelp = true;
    end
    
    methods
        function ci = method(classWrapper, packageName, className, methodName, definition, minimalPath, whichTopic)
            ci@helpUtils.classInformation.classElement(packageName, className, methodName, definition, minimalPath, whichTopic);
            ci.classWrapper = classWrapper;
            ci.isMethod = true;
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            if ci.inheritHelp
                [helpText, needsHotlinking, superClassInfo, ci.superWrapper] = ci.classWrapper.getShadowedHelp(ci.element, hotLinkCommand);
                if ~isempty(superClassInfo)
                    % definition needs to refer to the implementation
                    ci.definition = superClassInfo.definition;
                end
            else
                helpText = '';
                needsHotlinking = false;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/14 22:25:10 $
