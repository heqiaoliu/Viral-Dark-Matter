function getsnapshotdata(this,block)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:30:33 $

% Get the handle to the storage object;
snapshot_storage = LinearizationObjects.TimeEventStorage;

% Store the snapshot
Data = getopsnapshot(this,block.CurrentTime);
snapshot_storage.Data = [snapshot_storage.Data;Data];
