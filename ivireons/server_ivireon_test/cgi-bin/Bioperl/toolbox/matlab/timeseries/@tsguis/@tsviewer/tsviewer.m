function h = tsviewer
% Returns singleton instance of @tsviewer

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/07/14 15:27:42 $

mlock
persistent TSVIEWER;

if isempty(TSVIEWER) || ~ishandle(TSVIEWER)
    TSVIEWER = tsguis.tsviewer;
end

h =  TSVIEWER;