function customizeConstr(this,hC) 
% CUSTOMIZECONSTR customize the requirement for this visualization
%
% customizeConstr(this,hC)
%
% Inputs:
%   hC - handle to plotconstr.designconstr object
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/30 00:44:00 $

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
hC.setDisplayUnits('yunits',this.hPlot.Axes.YUnits{1});
pu = [this.hPlot.Axes.findprop('XUnits');this.hPlot.Axes.findprop('YUnits')];
L = handle.listener(this.hPlot.Axes,pu,'PropertyPostSet', {@LocalSetUnits,hC});

%Create listener for response changes
L = [L; handle.listener(this.hPlot, findprop(this.hPlot,'Responses'),'PropertyPostSet',{@LocalResponseChanged, this, hC});];
   
hC.addlisteners(L);
end

function LocalSetUnits(eventSrc,eventData,hC)
% Syncs constraint props with related Editor props

whichUnits = eventSrc.Name;
NewValue   = eventData.NewValue;
switch lower(whichUnits)
   case 'xunits'
      if isprop(hC,'FrequencyUnits')
         hC.setDisplayUnits(whichUnits,NewValue)
         hC.TextEditor.setDisplayUnits(lower(whichUnits),NewValue)
      end
   case 'yunits'
      if isprop(hC,'MagnitudeUnits')
         hC.setDisplayUnits(whichUnits,NewValue{1});
         hC.TextEditor.setDisplayUnits(lower(whichUnits),NewValue{1})
      end
end

% Update constraint display (and notify observers)
update(hC)
end

function LocalResponseChanged(~,hData,this,hC)
%React to response data changes.

%Do we need to redraw the constraint because the sample time changed?
%Only need to check when the first/last response changes as all responses
%have the same sample time.
if isprop(hC,'Ts') && (numel(hData.NewValue) == 1)
   Ts = hData.NewValue.DataSrc(1).Model.Ts;
   if ~isempty(Ts) && ~isequal(Ts,hC.Ts)
      hReqTool = this.Application.getExtInst('Tools:Requirement viewer');
      hReqTool.PreventVisUpdate = true;
      hC.Ts = Ts;  %Fires a constraint redraw
      hReqTool.PreventVisUpdate = false;
      hReqTool.isDirty = false;
   end
end
end