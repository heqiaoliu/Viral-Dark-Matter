function ssPortBlkPortHs = getSubsystemIOPortHs(ssInBlkHs, ssOutBlkHs, ssTriggerBlkHs)
    %getSubsystemIOPortHs  Returns vectors in/out port handles
    %   Returns vector containing:
    %   - output port handle of subsystem inport blocks and
    %   - input port handle of subsystem outport blocks

%   Copyright 2008-2009 The MathWorks, Inc.
    if nargin<3
        ssTriggerBlkHs = [];
    end

    bh = [ssInBlkHs; ssOutBlkHs];
    ssPortBlkPortHs = zeros(1,length(bh)+length(ssTriggerBlkHs));
    for idx = 1 : length(bh)
        bType     = get_param(bh(idx), 'BlockType');
        bpHandles = get_param(bh(idx), 'porthandles');

        if strcmpi(bType,'Inport')
            ph = bpHandles.Outport;
        else
            ph = bpHandles.Inport;
        end
        
        ssPortBlkPortHs(idx) = ph; 
    end    
    if ~isempty(ssTriggerBlkHs)
        subsystem = get_param(ssTriggerBlkHs,'Parent');
        bpHandles = get_param(subsystem,'PortHandles');
        ssPortBlkPortHs(length(bh)+1) = bpHandles.Trigger;
    end
end

% LocalWords:  porthandles
