function boolInSubSystem = isInSubsysToScale(h, topSubSystemToScale)
%ISINSUBSYSTOSCALE determines if the current block is in the subsystem to
%scale
%
%   Author(s) : V.Srinivasan
%   Copyright 2008-2010 The MathWorks, Inc.
%   $ Revision: $     $Date: 2010/05/20 02:18:31 $

blkDiagram = bdroot(topSubSystemToScale.getFullName);
% get the subsystem object that masks the Stateflow Chart object and check if this object is within the subsystem to scale.
subsys = fxptui.getsfsubsys(h);
if isequal(subsys, topSubSystemToScale)
    boolInSubSystem = true;
    return;
else
    curBlkObj = subsys;
    while ~isequal(topSubSystemToScale, curBlkObj.getParent)
      curBlkObj= curBlkObj.getParent;
      % If the stateflow data that is referenced from a Linked chart points to a
      % library chart, we don't want to autoscale the data. This data is read-only
      if isequal(curBlkObj.getFullName, blkDiagram) || isLibrary(curBlkObj)
        boolInSubSystem = false;
        return;
      end
    end
    boolInSubSystem = true;
end

