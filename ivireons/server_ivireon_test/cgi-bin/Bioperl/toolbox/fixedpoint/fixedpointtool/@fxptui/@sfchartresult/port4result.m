function port = port4result(h)
%PORT4RESULT returns PORT for H

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:47 $

port = [];
outports = get_param(h.daobject.up.PortHandles.Outport, 'Object');
for idx = 1:numel(outports)
  port = outports(idx);
  if(iscell(port)); port = port{:}; end
  if(isequal(port.PortNumber, str2double(h.PathItem)))
    break;
  end
end

% [EOF]
