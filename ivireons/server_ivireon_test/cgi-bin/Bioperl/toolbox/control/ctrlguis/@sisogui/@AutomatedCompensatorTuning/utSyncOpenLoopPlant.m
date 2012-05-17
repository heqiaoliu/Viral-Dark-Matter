function PlantChanged = utSyncOpenLoopPlant(this)
%SYNCCOMPLIST  synchronize tunable compensator/loop in the compensator
%selection panel. It listens to the 'ConfigChange' event from LoopData.

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/07/18 15:50:13 $

% Ensure TunedLoopList is valid
if any(~ishandle(this.TunedLoopList))
    this.utSyncCompList;
end


% update open loop plant and fixed dynamics information
ssdataModel = utFactorizeLoop(this.TunedLoopList(this.IdxC),this.TunedCompList(this.IdxC));
newPlant = utCreateLTI(ssdataModel);  
if isequal(this.OpenLoopPlant,newPlant)
    PlantChanged = false;
else
    PlantChanged = true;
    this.OpenLoopPlant = newPlant;
end
