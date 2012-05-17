function msg = emptyDataMessage(this)
%EMPTYDATAMESSAGE The message for no data.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/04/21 21:49:11 $

if ~isRunning(this)
    msg = 'No data is available until the simulation starts.';
else
    msg = this.DataHandler.emptyFrameMsg;
end

% [EOF]
