function continueEventHandler(this, event) %#ok
%CONTINUEEVENTHANDLER React to the ContinueEvent.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/31 18:42:29 $

if ~this.PlayPauseButton
    this.stepFwd = false;
end

startVisualUpdater(this);

% [EOF]
