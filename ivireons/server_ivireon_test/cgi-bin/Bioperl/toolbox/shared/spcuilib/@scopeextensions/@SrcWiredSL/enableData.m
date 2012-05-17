function enableData(this)
%ENABLEDATA Update the visual if we have data.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:42:30 $

% Do not send data to the visual if we are in a "starting" state.  When we
% are starting up we have no data because mdlUpdate has not been called.
% However, this can also be called when changing the visual, we want to
% send over the old data in this case.
if ~(this.IsStarting || isDataEmpty(this))
    updateVisual(this);
end

% [EOF]
