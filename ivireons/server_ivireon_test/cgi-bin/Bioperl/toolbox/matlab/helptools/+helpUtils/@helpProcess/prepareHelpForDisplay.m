function prepareHelpForDisplay(hp)
    if ~isempty(hp.helpStr)
        if hp.wantHyperlinks && hp.needsHotlinking
            % Make "see also", "overloaded methods", etc. hyperlinks.
            hp.hotlinkHelp;
        end

        hp.getDocTopic;
        if ~isempty(hp.docTopic) && hp.commandIsHelp
            hp.addMoreInfo('Reference page in Help browser', 'doc', hp.docTopic);
        end

        if ~hp.isDir
            demoTopic = hp.getDemoTopic;
            if ~isempty(demoTopic)
                hp.addMoreInfo('Published output in the Help browser', 'showdemo', demoTopic);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/18 20:49:02 $
