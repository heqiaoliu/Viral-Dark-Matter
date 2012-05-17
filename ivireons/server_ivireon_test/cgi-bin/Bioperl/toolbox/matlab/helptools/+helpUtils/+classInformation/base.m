classdef base < handle
    properties (SetAccess=protected, GetAccess=public)
        minimalPath = '';
        definition = '';
        
        isPackage = false;
        isMethod = false;
        isProperty = false;
    end
    
    properties
        isAccessible = true;
    end

    properties (SetAccess=protected, GetAccess=protected)
        whichTopic = '';
    end

    properties (SetAccess=public, GetAccess=private)
        unaryName = '';
        isMinimal = false;
    end

    methods
        function ci = base(definition, minimalPath, whichTopic)
            ci.definition = definition;
            ci.minimalPath = minimalPath;
            ci.whichTopic = whichTopic;
        end
        
        function whichTopic = minimizePath(ci)
            whichTopic = ci.whichTopic;
            if ~isempty(ci.minimalPath)
                if ci.isMinimal
                    pathParts = regexp(ci.minimalPath, '^(?<qualifyingPath>[^@+]*)(?(qualifyingPath)[\\/])(?<pathItem>.*)', 'names', 'once');
                    ci.minimalPath = pathParts.pathItem;                    
                else
                    ci.minimalPath = helpUtils.minimizePath(ci.minimalPath, ci.isPackage || ci.isConstructor);
                end
            end
        end
        
        function insertClassName(ci) %#ok<MANU>
        end

        function [helpText, needsHotlinking] = getHelp(ci, hotLinkCommand, topic, wantHyperlinks)
            if nargin < 4
                wantHyperlinks = 0;
                if nargin < 3
                    topic = '';
                    if nargin < 2
                        hotLinkCommand = '';
                    end
                end
            end
            ci.overqualifyTopic(topic);
            [helpText, needsHotlinking] = ci.innerGetHelp(hotLinkCommand);
            if ~isempty(helpText)
                helpText = ci.postprocessHelp(helpText, wantHyperlinks);
            end
        end

        function [helpText, needsHotlinking] = innerGetHelp(ci, hotLinkCommand)
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
            if isempty(helpText)
                [helpText, needsHotlinking] = ci.getSecondaryHelp(hotLinkCommand);
            end
        end
        
        function b = hasHelp(ci)
            b = checkHelp(ci);
        end
        
        function b = checkHelp(ci)
            b = builtin('helpfunc', ci.definition, '-justChecking');
        end
        
        function docTopic = getDocTopic(ci, ~)
            docTopic = innerGetDocTopic(ci, ci.fullTopic);
        end
        
        function set.unaryName(ci, name)
            if ~isempty(regexp(name, '^\w*$', 'once'))
                ci.unaryName = helpUtils.extractCaseCorrectedName(ci.definition, name); %#ok<MCSUP>
            end
        end
        
        function [helpText, needsHotlinking] = getSecondaryHelp(ci, ~) %#ok<MANU>
            helpText = '';
            needsHotlinking = false;
        end
            
        function topic = fullTopic(ci)
            topic = ci.definition;
        end

        function b = isClass(ci) %#ok<MANU>
            b = false;
        end

        function b = isConstructor(ci) %#ok<MANU>
            b = false;
        end

        function b = isMCOSClass(ci) %#ok<MANU>
            b = false;
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking] = helpfunc(ci, hotLinkCommand)
            [helpText, needsHotlinking] = builtin('helpfunc', ci.definition, '-hotlink', hotLinkCommand, '-actual', ci.unaryName);
        end

        function helpText = postprocessHelp(ci, helpText, ~) %#ok<MANU>
        end

        function overqualifyTopic(ci, ~) %#ok<MANU>
        end
        
        function docTopic = innerGetDocTopic(ci, topic)
            isClassElement = false;
            name = topic;
            slashIndex = find(name=='/', 1, 'last');
            if ~isempty(slashIndex)
                isClassElement = true;
                name(slashIndex) = '.';                        
            end
            docTopic = helpUtils.getDocTopic(ci.definition, name, isClassElement);
        end        
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.12 $  $Date: 2009/12/14 22:24:58 $
