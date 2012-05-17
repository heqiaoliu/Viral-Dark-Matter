function boolInSubSystem = isInSubsysToScale(h, topSubSystemToScale)
%ISINSUBSYSTOSCALE determines if the current block is in the subsystem to
%scale
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $         $Date: 2008/12/01 07:13:32 $

curBlkObj = h.daobject; 
blkDiagram = bdroot(topSubSystemToScale.getFullName);

while ~isequal(topSubSystemToScale, curBlkObj.getParent)
    % If you have a Simulink model in stateflow, the Parent that is
    % returned can be a state/chart. In this case, get the subsystem object
    % that masks the Chart object and check if it is in the subsystem to
    % scale.
    if (isa(curBlkObj, 'Stateflow.Chart') || isa(curBlkObj, 'Stateflow.EMChart') || isa(curBlkObj, 'Stateflow.TruthTableChart'))
        curBlkObj = curBlkObj.up;
        if isequal(topSubSystemToScale, curBlkObj)
            boolInSubSystem = true;
            return;
        end
    else
        curBlkObj= curBlkObj.getParent;
    end
    if isequal(curBlkObj.getFullName, blkDiagram)
        boolInSubSystem = false;
        return;
    end
end
boolInSubSystem = true;
end

