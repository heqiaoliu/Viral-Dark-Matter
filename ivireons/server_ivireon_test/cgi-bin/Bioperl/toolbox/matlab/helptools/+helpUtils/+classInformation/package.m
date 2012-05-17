classdef package < helpUtils.classInformation.base
    properties (SetAccess=private, GetAccess=private)
        isExplicit = false;
    end
    
    methods
        function ci = package(packagePath, isExplicit)
            ci@helpUtils.classInformation.base(helpUtils.getPackageName(packagePath), packagePath, packagePath);
            ci.isExplicit = isExplicit;
            ci.isPackage = true;
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            % this is called when help for a package has not been found
            % since the definition has been modified by overqualifyTopic,
            % change it back, so the no help found message is nice.
            ci.definition = helpUtils.getPackageName(ci.whichTopic);
            helpText = '';
            needsHotlinking = false;
        end
    end

    methods (Access=protected)
        function overqualifyTopic(ci, topic)
            % if a package name has been overqualified to distinguish it from
            % another directory, add it back here
            overqualifiedPath = helpUtils.splitOverqualification(ci.definition, topic, ci.whichTopic);
            if ci.isExplicit
                ci.definition = [overqualifiedPath, ci.minimalPath];
            else
                ci.definition = [overqualifiedPath, regexprep(ci.minimalPath, '[@+]', '')];
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $  $Date: 2009/12/14 22:25:11 $
