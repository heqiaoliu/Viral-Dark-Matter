function out = isAtomicSubchartSubsystem(sfSubsystemH)

%   Copyright 2010 The MathWorks, Inc.

    out = isStateflowBlock(sfSubsystemH) && ...
        isStateflowBlock(get_param(get_param(sfSubsystemH, 'Parent'),'Handle'));    
end

function yn = isStateflowBlock(blockH)
    yn = strcmp(get_param(blockH, 'Type'), 'block') && ...
        strcmp(get_param(blockH,'BlockType'),'SubSystem') && ...
        strcmp(get_param(blockH,'MaskType'),'Stateflow');
end