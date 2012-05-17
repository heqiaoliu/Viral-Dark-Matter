function remove_demux_port_name(portH)
% Remove the "name" of an Demux blocks output port. Otherwise, whatever
% line is drawn from this output port gets the name which is lying around
% in here.

%   Copyright 2008 The MathWorks, Inc.

% Should only get called for Demux objects.
if ~strcmpi(get_param(portH, 'BlockType'), 'Demux')
    return
end

portHandles = get_param(portH, 'PortHandles');
% should only have been called when there is a single output port for this
% Demux block.
outportH = portHandles.Outport;
if length(outportH) == 1 && ishandle(outportH)
    set_param(outportH, 'name', '');
end
