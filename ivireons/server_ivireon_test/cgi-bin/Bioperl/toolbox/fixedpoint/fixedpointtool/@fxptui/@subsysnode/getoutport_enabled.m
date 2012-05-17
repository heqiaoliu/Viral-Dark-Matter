function str = getoutport_enabled(h)
%GETOUTPORT_ENABLED returns 'On' or 'Off' if the block has an outport

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/20 07:54:10 $

% This may be a subsysnode that is wrapping a Stateflow SLFunction
% object.
if ~isa(h.daobject,'Stateflow.SLFunction')
    if(numel(h.daobject.PortHandles.Outport) > 0)
        str = 'On';
    else
        str = 'Off';
    end
else
    str = 'off'; % Stateflow.SLFunction objects are wrappers of other objects and don't have any output ports.
end
% [EOF]
