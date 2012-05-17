function resultnode = snapshot_linearize(this,io,snapshottimes_Str,opt)
% SNAPSHOT_LINEARIZE  Linearize the model using snapshots
%

% Author(s): John W. Glass 16-Aug-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/31 07:36:02 $

% Evaluate the snapshot times
SnapShotTimes = GenericLinearizationNodes.evalSnapshotVector(snapshottimes_Str);

% Linearize the model
[resultnode,op_ss] = Linearize(this,io,SnapShotTimes,opt);

% Add the operating points to the result node
for ct = 1:numel(op_ss)
    str = ctrlMsgUtils.message('Slcontrol:linutil:OperatingPointTimeNote',mat2str(op_ss(ct).Time));
    op_node = OperatingConditions.LinearizationOperPointSnapshotPanel(op_ss(ct),str);
    resultnode.addNode(op_node);
end
