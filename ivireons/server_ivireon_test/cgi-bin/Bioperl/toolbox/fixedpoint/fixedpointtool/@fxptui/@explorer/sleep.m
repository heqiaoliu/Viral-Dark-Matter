function sleep(h)
%SLEEP    put explorer to sleep if it isn't already

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/20 07:54:02 $

%turn property change listeners off while we update the properties of
%displayed data. (prevent flickering)
ed = DAStudio.EventDispatcher;
% Maintain a count of the number of SleepEvents we have introduced.
h.SleepCntr = h.SleepCntr+1;
ed.broadcastEvent('MESleepEvent');

% [EOF]
