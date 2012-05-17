function customizeConstr(this,hC) 
% CUSTOMIZECONSTR customize the requirement for this visualization
%
% customizeConstr(this,hC)
%
% Inputs:
%   hC - handle to plotconstr.designconstr object
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:55 $

%Set the requirement patch color based on enabled state of bounds
hBlk = this.Application.DataSource.BlockHandle;
hReq = hC.getRequirementObject;
if isa(hReq,'srorequirement.gainphasemargin') && strcmp(hBlk.EnableMargins,'on') || ...
     isa(hReq,'srorequirement.nicholspeak') && strcmp(hBlk.EnableCLPeakGain,'on')  || ...
     isa(hReq,'srorequirement.nicholslocation') && strcmp(hBlk.EnableGainPhaseBound,'on') 
   PatchColor = this.hPlot.Options.RequirementColor;
else
   PatchColor = this.hPlot.Options.DisabledRequirementColor;
end
set(hC,'PatchColor',PatchColor,'ZLevel',-2);

%Set constraint display units and create listeners for axes unit changes
hC.setDisplayUnits('xunits',this.hPlot.Axes.XUnits);
hC.setDisplayUnits('yunits',this.hPlot.Axes.YUnits);
pu = [this.hPlot.Axes.findprop('XUnits');this.hPlot.Axes.findprop('YUnits')];
L = handle.listener(this.hPlot.Axes,pu,'PropertyPostSet', {@LocalSetUnits, hC});
   hC.addlisteners(L);
end

function LocalSetUnits(eventSrc,eventData,hC)
% Syncs constraint props with related Editor props

whichUnits = lower(eventSrc.Name);
NewValue   = eventData.NewValue;
hC.setDisplayUnits(whichUnits,NewValue);
hC.TextEditor.setDisplayUnits(whichUnits,NewValue);

% Update constraint display (and notify observers)
update(hC)
end