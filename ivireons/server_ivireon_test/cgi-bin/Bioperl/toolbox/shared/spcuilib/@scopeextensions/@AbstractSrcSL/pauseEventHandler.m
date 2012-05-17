function pauseEventHandler(this, event) %#ok
%PAUSEVENTHANDLER React to the PauseEvent.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/31 18:41:06 $

% If we're not in snapshotmode, make sure that we have the correct
% time in the TimeOfDisplayData field.
updateSimTimeReadout(this);

% Stop the VisualUpdater Timer.  This fires the callback to update the time
% one last time with the new time information.
stopVisualUpdater(this);

% [EOF]
