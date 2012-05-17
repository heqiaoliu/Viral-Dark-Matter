function displayHelp(hp)
    if ~hp.suppressDisplay
        if ~isempty(hp.helpStr)
            disp(hp.helpStr);
        else
            if ~isempty(hp.fullTopic)
                if ~isempty(hp.objectSystemName)
                    correctName = hp.objectSystemName;
                else
                    correctName = helpUtils.extractCaseCorrectedName(hp.fullTopic, hp.topic);
                    if isempty(correctName)
                        correctName = hp.topic;
                    elseif isempty(regexp(correctName, '\.\w+$', 'once'))
                        correctName = [correctName regexp(hp.fullTopic, '\.\w+$', 'match', 'once')];
                    end
                end
                fprintf('\nNo help found for %s.\n\n', correctName);
            else
                unknownTopic = false;
                if ~isempty(hp.topic)
                    if ~helpUtils.isObjectDirectorySpecified(fileparts(hp.topic)) && ~isempty(helpUtils.hashedDirInfo(hp.topic))
                        fprintf('\nNo help found for %s.\n\n', hp.topic);
                    else
                        fprintf('\n%s not found.\n\n', hp.topic);
                        unknownTopic = true;
                    end
                end
                if unknownTopic
                    if hp.wantHyperlinks
                        fprintf('Use the Help browser search field to <a href="matlab:%s">search the documentation</a>, or\ntype "<a href="matlab:help help">help help</a>" for help command options, such as help for methods.\n\n', helpUtils.makeDualCommand('docsearch', hp.topic));
                    else
                        fprintf('Use the Help browser search field to search the documentation, or\ntype "help help" for help command options, such as help for methods.\n\n');
                    end
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/21 21:32:20 $
