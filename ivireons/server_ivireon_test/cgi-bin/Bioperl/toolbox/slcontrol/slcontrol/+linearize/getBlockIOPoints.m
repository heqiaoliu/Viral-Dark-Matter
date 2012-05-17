function newio = getBlockIOPoints(block)
% GETBLOCKLINIO Computes the linearization IO for a block specified by a
% user.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:35:06 $

% Get the new IO for block linearization
newio = [];
% Get ready to create the I/O required for linearization
hio = linearize.IOPoint;
% Set the Block and PortNumber properties
hio.Type = 'out';
% Get the full block name
ph = block.PortHandles;
% Block must either have an inport of outport
ph = [ph.Inport ph.Outport];
if isempty(ph)
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidBlocktoLinearize',getfullname(block.handle))
end
hio.Block = get_param(ph(1),'Parent');
% Set the openloop property to be on
hio.OpenLoop = 'on';
% Loop over each outport
for ct = 1:length(block.PortHandles.Outport)
    hio.PortNumber = ct;
    hio.Description = sprintf('%d',ct);
    newio = [newio;hio.copy];
end
% Get the source block
hio.Type = 'in';
% Loop over each input
for ct = 1:length(block.PortHandles.Inport)
    SourceBlock = get_param(block.PortConnectivity(ct).SrcBlock,'Object');
    SourcePort = block.PortConnectivity(ct).SrcPort + 1;
    if (SourcePort <= length(SourceBlock.PortHandles.Outport))
        hio.Block = get_param(SourceBlock.PortHandles.Outport(SourcePort),'Parent');
    else
        ctrlMsgUtils.error('Slcontrol:linutil:InvalidBlocktoLinearizeDrivenbyStatePort',getfullname(block.handle))
    end
    % Get the source port
    hio.PortNumber = SourcePort;
    hio.Description = sprintf('%d',ct);
    newio = [newio;hio.copy];
end