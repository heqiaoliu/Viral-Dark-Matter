function busLabelSetup(this,io) 
% BUSLABELSETUP
%
% Sets up necessary properties for bus name labeling. 

% Author(s): Erman Korkut
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2008/10/31 06:58:29 $

util = slcontrol.Utilities;

if ~isempty(io)
    for ct = 1:length(io)
        ph = get_param(io(ct).Block,'PortHandles');
        h = ph.Outport(io(ct).PortNumber);
        blkh = getBlockHandle(util,io(ct).Block);
        % Set bus settings if block is Bus Creator or Subsystem Inport
        if ~isRootInport(util,blkh) && (isa(blkh,'Simulink.Inport') || isa(blkh,'Simulink.BusCreator'))
            set_param(h,'CacheCompiledBusStruct','on');
        elseif isa(blkh,'Simulink.SubSystem')
            % Set bus settings if the io is placed at the output of a subsystem
            outport = find_system(io(ct).Block,'SearchDepth',1,'BlockType','Outport','Port',num2str(io(ct).PortNumber));
            ph = get_param(outport{1},'PortHandles');
            set_param(ph.Inport,'CacheCompiledBusStruct','on');
        end
    end
else % Root-level linearization, mark the signals feeding into outports for CacheCompiledBusStruct
    blocks = find_system(this.Model,'SearchDepth',1,'BlockType','Outport');
    for ct = 1:length(blocks)
        ph = get_param(blocks{ct},'PortHandles');
        % Set the output port to be cached
        set_param(ph.Inport,'CacheCompiledBusStruct','on');
    end
end
    
