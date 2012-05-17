function customizeConstr(this,hC) 
% CUSTOMIZECONSTR customize the requirement for this visualization
%
% customizeConstr(this,hC)
%
% Inputs:
%   hC - handle to plotconstr.designconstr object
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:55 $

%Set the requirement patch color based on enabled state of bounds
hBlk = this.Application.DataSource.BlockHandle;
if strcmp(hBlk.EnableStepResponseBound,'on')
   PatchColor = this.hPlot.Options.RequirementColor;
else
   PatchColor = this.hPlot.Options.DisabledRequirementColor;
end
set(hC,'PatchColor',PatchColor);

%Disable the flip menu for the requirement
hC.AllowContextMenu = struct('flip','off');
end