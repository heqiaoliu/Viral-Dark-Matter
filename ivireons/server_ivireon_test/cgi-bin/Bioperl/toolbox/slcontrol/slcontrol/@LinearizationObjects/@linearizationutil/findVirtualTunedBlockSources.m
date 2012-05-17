function vportios = findVirtualTunedBlockSources(this,TunedBlocks)
% FINDVIRTUALTUNEDBLOCKSOURCES Find the tuned blocks actual source.  If this 
% source port is larger then 1 then add a linearization point at the graphical 
% source.

% Author(s): John W. Glass 11-Sep-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/11/09 16:35:14 $

vportios = [];

for ct = 1:numel(TunedBlocks)
    % Get the actual src of the tuned block
    if isfield(TunedBlocks(ct),'AuxData')
        InportPort = TunedBlocks(ct).AuxData.InportPort;
        OutportPort = TunedBlocks(ct).AuxData.OutportPort;
    else
        ph = get_param(TunedBlocks(ct).Name,'PortHandles');
        InportPort = 1:numel(ph.Inport);
        OutportPort = 1:numel(ph.Outport);
    end
    % Create the linearization IOs for the block
    for dt = 1:numel(InportPort)
        pc = get_param(TunedBlocks(ct).Name,'PortConnectivity');
        vportios = [vportios;linio(getfullname(pc(InportPort(dt)).SrcBlock),...
            pc(InportPort(dt)).SrcPort+1,'out')];
    end
    for dt = 1:numel(OutportPort)
        vportios = [vportios;linio(TunedBlocks(ct).Name,...
            OutportPort(dt),'in')];
    end
end