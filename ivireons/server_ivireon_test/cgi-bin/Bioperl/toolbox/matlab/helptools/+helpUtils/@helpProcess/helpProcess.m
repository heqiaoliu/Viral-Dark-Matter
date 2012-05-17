classdef helpProcess < handle
    properties (SetAccess=private, GetAccess=public)
        helpStr = '';
        docTopic = '';
    end

    properties (SetAccess=private, GetAccess=private)
        suppressDisplay = false;
        wantHyperlinks = false;
        commandIsHelp = true;

        command = '';
        topic = '';
        fullTopic = '';

        isDir = false;
        isContents = false;
        isOperator = false;
        needsHotlinking = false;
        objectSystemName = '';
        isMCOSClass = false;
    end

    methods
        function hp = helpProcess(nlhs, nrhs, prhs)
            hp.suppressDisplay = (nlhs ~= 0);
            if ~hp.suppressDisplay
                hp.wantHyperlinks = feature('hotlinks');
                if hp.wantHyperlinks
                    hp.command = 'help';
                end
            end

            commandSpecified = false;
            topicSpecified = false;

            for i = 1:nrhs
                arg = prhs{i};
                switch arg
                case {'-help', '-helpwin', '-doc'}
                    if commandSpecified
                        hp.suppressDisplay = true;
                        throwAsCaller(MException('MATLAB:help:TooManyCommands', 'Only one command option may be specified'));
                    end
                    hp.command = arg(2:end);
                    hp.commandIsHelp = strcmp(hp.command, 'help');
                    hp.wantHyperlinks = true;
                    commandSpecified = true;
                otherwise
                    if topicSpecified
                        hp.suppressDisplay = true;
                        throwAsCaller(MException('MATLAB:help:TooManyInputs', 'Help only supports one topic'));
                    end
                    hp.topic = arg;
                    topicSpecified = true;
                end
            end
        end

        getHelpText(hp);
        prepareHelpForDisplay(hp);

        function delete(hp)
            hp.displayHelp;
        end
    end

    methods (Access=private)
        hotlinkHelp(hp);
        getTopicHelpText(hp);
        getDocTopic(hp);
        demoTopic = getDemoTopic(hp);
        addMoreInfo(hp, infoStr, infoCommand, infoArg);
        displayHelp(hp);
        [qualifyingPath, pathItem] = getPathItem(hp);
        extractFromClassInfo(hp, classInfo);
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/12/14 22:25:32 $
