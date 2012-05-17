function msg = emptyDataMessage(this)
%EMPTYDATAMESSAGE Displays text when there is no data available
%   OUT = EMPTYDATAMESSAGE(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:40:40 $

% This is used to display text when there is no data. We display nothing
% when there is no data.

msg = this.DataHandler.emptyFrameMsg;

% [EOF]
