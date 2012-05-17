function setlogging_outports(h, state)
%SETLOGGING_OUTPORTS Set signal logging for the outports in this system

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:34 $

outports = get_param(h.daobject.PortHandles.Outport, 'Object');
for idx = 1:numel(outports)
  port = outports(idx);
  if(iscell(port)); port = port{:}; end
  port.TestPoint = state;
  port.DataLogging = state;
end

% [EOF]
