function PlantChanged = utSyncOpenLoopPlant(this)
%SYNCCOMPLIST  synchronize tunable compensator/loop in the compensator
%selection panel. It listens to the 'ConfigChange' event from LoopData.

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:25:09 $

%% update open loop plant and fixed dynamics information
% deal with IMC configuration specially
if this.LoopData.getconfig == 5
    ssdataModel = this.LoopData.Plant.G(2).SSData;
    newPlant = this.LoopData.Plant.LoopSign*utCreateLTI(ssdataModel);
else
    ssdataModel = utFactorizeLoop(this.TunedLoopList(this.IdxC),this.TunedCompList(this.IdxC));
    newPlant = utCreateLTI(ssdataModel);  
end
if isequal(this.OpenLoopPlant,newPlant)
    PlantChanged = false;
else
    PlantChanged = true;
    this.OpenLoopPlant = newPlant;
end

