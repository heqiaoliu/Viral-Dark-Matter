function out = isInOutportBlkDataTypeBus(blockH)

%   Copyright 2010 The MathWorks, Inc.

    assert(any(strcmp(get_param(blockH,'BlockType'),{'Inport','Outport'})));
    dataType = get_param(blockH, 'OutDataTypeStr');
    out = strncmp(dataType, 'Bus:', length('Bus:'));
end