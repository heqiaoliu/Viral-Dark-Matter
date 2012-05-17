function getTopicHelpText(hp)
    hp.isOperator = helpUtils.isOperator(hp.topic);

    [hp.topic, ~, ~, ~, hasLocalFunction] = helpUtils.fixLocalFunctionCase(hp.topic, '', false);

    if ~hasLocalFunction && ~hp.isOperator
        [classInfo, hp.fullTopic, malformed] = helpUtils.splitClassInformation(hp.topic, '', false, false);
        if ~isempty(classInfo)
            if classInfo.isAccessible
                [hp.helpStr, hp.needsHotlinking] = classInfo.getHelp(hp.command, hp.topic, hp.wantHyperlinks);
                hp.isMCOSClass = classInfo.isMCOSClass;
            end

            hp.extractFromClassInfo(classInfo);
            return;
        end

        if malformed
            return;
        end

        [hp.topic, ~, hp.fullTopic, ~, alternateHelpFunction] = helpUtils.fixFileNameCase(hp.topic, '', hp.fullTopic);

        if ~isempty(alternateHelpFunction)
            hp.helpStr = helpUtils.callHelpFunction(alternateHelpFunction, hp.fullTopic);
            hp.needsHotlinking = true;
            [~, hp.topic] = fileparts(hp.fullTopic);
            return;
        end
    end

    [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', hp.topic, '-hotlink', hp.command);
    if ~isempty(hp.helpStr) && ~hasLocalFunction
        helpFor = regexpi(hp.helpStr, sprintf(' --- help for %s ---\n\n', '(?<topic>[\w\\/.@+]*)'), 'names', 'once');
        if ~isempty(helpFor)
            hp.extractFromClassInfo(helpFor.topic);
        else 
            dirInfos = helpUtils.hashedDirInfo(hp.topic)';
            if isempty(hp.fullTopic)
                for dirInfo = dirInfos
                    hp.fullTopic = helpUtils.extractCaseCorrectedName(dirInfo.path, hp.topic);
                    if ~isempty(hp.fullTopic)
                        hp.topic = helpUtils.minimizePath(hp.fullTopic, true);
                        hp.isDir = true;
                        return;
                    end
                end
            else
                [~, hp.topic] = hp.getPathItem;
                if strcmp(hp.topic, 'handle')
                    hp.isMCOSClass = true;
                elseif ~hp.isDir
                    hp.isDir = ~isempty(dirInfos);
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2009/05/18 20:48:59 $
