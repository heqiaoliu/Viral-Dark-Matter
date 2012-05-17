function updateSimTimeReadout(this)
%UPDATESIMTIMEREADOUT Update the simulation time readout.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:08:21 $

hModel = getParentModel(this);
if ~this.SnapShotMode && ~isempty(hModel)
    this.TimeOfDisplayData = get(hModel, 'SimulationTime');
end

% [EOF]
