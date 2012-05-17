function h = recorder
% Returns singleton instance of @recorder class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:56:36 $

mlock
persistent thisrecorder;

if isempty(thisrecorder) || ~ishandle(thisrecorder)
    thisrecorder = tsguis.recorder;
end

h =  thisrecorder;
