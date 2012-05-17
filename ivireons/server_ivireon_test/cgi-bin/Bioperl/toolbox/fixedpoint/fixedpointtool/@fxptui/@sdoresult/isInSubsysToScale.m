function boolInSubSystem = isInSubsysToScale(h, topSubSystemToScale)
%ISINSUBSYSTOSCALE determines if the current block is in the subsystem to
%scale
%   Detailed explanation goes here

%   Copyright 2008 The MathWorks, Inc.

boolInSubSystem = false;
blkDiagram = bdroot(topSubSystemToScale.getFullName);
appData = SimulinkFixedPoint.getApplicationData(blkDiagram);
% list of blocks that share the same actual source block
% could be multiple source blocks
actualSrcBlocks = h.actualSrcBlk;
for i = 1:numel(actualSrcBlocks)
    srcResultList = appData.dataset.getblklist4src(appData.scaleUsing, actualSrcBlocks{i});
    for j = 1:numel(srcResultList)
        if ~isa(srcResultList(j), 'fxptui.sdoresult')
            isInSubsysToScale = srcResultList(j).isInSubsysToScale(topSubSystemToScale);
            if isInSubsysToScale
                boolInSubSystem = true;
                return;
            end
        end
    end
end



