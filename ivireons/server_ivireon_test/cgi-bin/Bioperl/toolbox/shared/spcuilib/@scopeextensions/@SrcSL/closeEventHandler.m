function closeEventHandler(this, event)
%CLOSEEVENTHANDLER React to the Simulink CloseEvent.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/13 15:28:48 $

clearDisplay(this);
releaseData(this.Application);

% [EOF]
