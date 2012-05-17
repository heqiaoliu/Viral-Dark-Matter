function extractFromClassInfo(hp, classInfo)
    if ischar(classInfo)
        [classInfo, hp.fullTopic] = helpUtils.splitClassInformation(classInfo, '', false, false);
        if isempty(classInfo)
            return;
        end
    end
    hp.topic = classInfo.minimalPath;
    hp.isDir = classInfo.isPackage;

    hp.objectSystemName = classInfo.fullTopic;
    if ~isempty(classInfo.getDocTopic(true))
        hp.docTopic = hp.objectSystemName;
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/08 21:54:37 $
