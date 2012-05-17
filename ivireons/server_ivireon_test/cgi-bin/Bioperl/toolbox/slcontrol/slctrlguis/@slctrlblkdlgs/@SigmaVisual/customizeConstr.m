function customizeConstr(this,hC) 
% CUSTOMIZECONSTR customize the requirement for this visualization
%
% customizeConstr(this,hC)
%
% Inputs:
%   hC - handle to plotconstr.designconstr object
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:57 $

%Set the requirement patch color based on enabled state of bounds
hBlk = this.Application.DataSource.BlockHandle;
hReq = hC.getRequirementObject;
if hReq.isLowerBound && strcmp(hBlk.EnableLowerBound,'on') || ...
     ~hReq.isLowerBound && strcmp(hBlk.EnableUpperBound,'on') 
   PatchColor = this.hPlot.Options.RequirementColor;
else
   PatchColor = this.hPlot.Options.DisabledRequirementColor;
end
set(hC,'PatchColor',PatchColor);

%Disable the flip menu for the requirement
hC.AllowContextMenu = struct('flip','off');

%Set constraint display units and create listeners for axes unit changes
hC.setDisplayUnits('xunits',this.hPlot.Axes.XUnits);
hC.setDisplayUnits('yunits',this.hPlot.Axes.YUnits);
pu = [this.hPlot.Axes.findprop('XUnits');this.hPlot.Axes.findprop('YUnits')];
L = handle.listener(this.hPlot.Axes,pu,'PropertyPostSet', {@LocalSetUnits,hC});
hC.addlisteners(L);
end

function LocalSetUnits(eventSrc,eventData,hC)
% Syncs constraint props with related Editor props

whichUnits = eventSrc.Name;
NewValue   = eventData.NewValue;
hC.setDisplayUnits(whichUnits,NewValue)
hC.TextEditor.setDisplayUnits(lower(whichUnits),NewValue)

% Update constraint display (and notify observers)
update(hC)
end