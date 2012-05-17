function getHelpText(hp)
    if ~isempty(hp.topic)
        hp.getTopicHelpText;
        if ~isempty(hp.helpStr)
            return;
        end
    else
        [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', '-hotlink', hp.command);
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/14 22:25:30 $
