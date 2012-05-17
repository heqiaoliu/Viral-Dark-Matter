function [qualifyingPath, pathItem] = getPathItem(hp)
    [qualifyingPath, pathItem, ext] = fileparts(hp.fullTopic);
    if ~hp.isDir
        hp.isContents = strcmp(pathItem, 'Contents') && strcmp(ext, '.m');
        if hp.isContents
            hp.isDir = true;
            pathItem = helpUtils.minimizePath(qualifyingPath, true);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/18 20:48:58 $
