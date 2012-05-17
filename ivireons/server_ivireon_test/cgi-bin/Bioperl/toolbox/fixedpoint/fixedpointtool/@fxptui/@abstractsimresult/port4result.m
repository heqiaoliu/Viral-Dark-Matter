function port = port4result(h)
%PORT4RESULT returns PORT for H

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:27 $

port = [];
outports = get_param(h.daobject.PortHandles.Outport, 'Object');
%if there is only one outport, return it
if(numel(outports) == 1)
  port = outports;
%otherwise only assign it if there is a Signal  
else
%   if(isempty(h.Signal)); return; end
  for idx = 1:numel(outports)
    port = outports(idx);
    if(iscell(port)); port = port{:}; end
    if(isequal(port.PortNumber, str2double(h.PathItem)))
      break;
    end
  end
end

% [EOF]
