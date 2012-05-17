function pauseEventHandler(this, event)  %#ok<INUSD>
%PAUSEVENTHANDLER React to the PauseEvent.
%

% Author(s): A. Stothert 05-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/30 00:40:06 $

% Stop the VisualUpdater Timer.  This fires the callback to update the time
% one last time with the new time information.
stopVisualUpdater(this);
end