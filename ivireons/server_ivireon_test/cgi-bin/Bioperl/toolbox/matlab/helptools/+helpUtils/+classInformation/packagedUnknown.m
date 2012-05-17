classdef packagedUnknown < helpUtils.classInformation.packagedItem
    properties
        helpFunction = '';
    end
    
    methods
        function ci = packagedUnknown(packageName, packagePath, itemName, itemFullName, helpFunction)
            ci@helpUtils.classInformation.packagedItem(packageName, packagePath, itemName, itemFullName);
            ci.helpFunction = helpFunction;
        end
    end
    
    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            helpText = helpUtils.callHelpFunction(ci.helpFunction, ci.whichTopic);
            needsHotlinking = true;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/14 22:25:14 $
