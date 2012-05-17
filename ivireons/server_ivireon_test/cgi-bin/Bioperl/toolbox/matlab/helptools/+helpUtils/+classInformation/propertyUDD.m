classdef propertyUDD < helpUtils.classInformation.property
    properties (SetAccess=private, GetAccess=private)
        classWrapper;
    end    
    
    methods
        function ci = propertyUDD(classWrapper, className, classPath, propertyName, packageName)
            ci = ci@helpUtils.classInformation.property(className, classPath, propertyName, packageName);
            ci.classWrapper = classWrapper;
        end

        function [helpText superClassInfo] = getSuperHelp(ci)
            helpText = ci.localHelp;
            if ci.foundProperty
                superClassInfo = ci;
            else
                [helpText, superClassInfo] = ci.classWrapper.getSuperPropertyHelp(ci.element);
            end
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            needsHotlinking = true;
            helpText = ci.localHelp;
            if ~ci.foundProperty
                [helpText, superClassInfo] = ci.classWrapper.getSuperPropertyHelp(ci.element);
                ci.definition = superClassInfo.definition;
                ci.superWrapper = superClassInfo.classWrapper;
            end
        end
    end
    
    methods (Static, Access=protected)
        function allPropertyHelps = getAllPropertyHelps(classFile)
            allPropertyHelps = regexp(classFile, '^(?<help>[ \t]*+%.*+\n)*.*\<schema\.prop[ \t]*\([^,]*,[ \t]*''(?<property>\w++)''', 'names', 'dotexceptnewline', 'lineanchors');
        end
        
        function [helpText, prependName] = extractHelpText(propertyHelp)
            prependName = true;
            helpText = propertyHelp.help;
        end
    end
    
    methods (Access=private)
        function helpText = localHelp(ci)
            classFileName = regexprep(ci.whichTopic, '\w*.m$', 'schema.m');
            helpText = getPropertyHelp(ci, classFileName);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/12/14 22:25:16 $
