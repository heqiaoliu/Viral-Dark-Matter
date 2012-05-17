classdef localConstructor < helpUtils.classInformation.constructor
    methods
        function ci = localConstructor(packageName, className, basePath, justChecking)
            definition = fullfile(basePath, [className filemarker className]);
            whichTopic = fullfile(basePath, [className '.m']);
            ci@helpUtils.classInformation.constructor(packageName, className, definition, whichTopic, justChecking);
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            % did not find help for the local constructor, see if there is help for the class
            ci.definition = ci.whichTopic;
            ci.minimalPath = ci.definition;
            ci.minimizePath;
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2009/12/14 22:25:08 $
