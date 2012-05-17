function val = setlogsignal(h, val)
%SETLOGSIGNAL Set the logsignal property

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:02 $

me = fxptui.getexplorer;
if(isempty(me)); return; end
if(isempty(h.daobject)); return; end
me.getRoot.enablesiglog;
state = 'Off';
if(val)
  state = 'On';
end
h.outport.TestPoint = state;
h.outport.DataLogging = state;

% [EOF]
