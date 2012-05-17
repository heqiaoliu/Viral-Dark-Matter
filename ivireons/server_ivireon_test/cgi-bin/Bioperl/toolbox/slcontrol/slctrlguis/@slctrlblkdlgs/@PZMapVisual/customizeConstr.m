function customizeConstr(this,hC) 
% CUSTOMIZECONSTR customize the requirement for this visualization
%
% customizeConstr(this,hC)
%
% Inputs:
%   hC - handle to plotconstr.designconstr object
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/30 00:44:17 $

%Set the requirement patch color based on enabled state of bounds
hBlk = this.Application.DataSource.BlockHandle;
hReq = hC.getRequirementObject;
if isa(hReq,'srorequirement.settlingtime') && strcmp(hBlk.EnableSettlingTime,'on') || ...
     isa(hReq,'srorequirement.natrualfrequency') && strcmp(hBlk.EnableNaturalFrequency,'on')  || ...
     isa(hReq,'srorequirement.dampingratio') && strcmp(hReq.Name,'overshoot') && strcmp(hBlk.EnablePercentOvershoot,'on') || ...
     isa(hReq,'srorequirement.dampingratio') && strcmp(hReq.Name,'damping') && strcmp(hBlk.EnableDampingRatio,'on')
   PatchColor = this.hPlot.Options.RequirementColor;
else
   PatchColor = this.hPlot.Options.DisabledRequirementColor;
end
set(hC,'PatchColor',PatchColor,'ZLevel',-2);

%Create listener for response changes, do this as the sample time may change 
%and will need to redraw the constraint
L = handle.listener(this.hPlot, findprop(this.hPlot,'Responses'),'PropertyPostSet',{@LocalResponseChanged, this, hC});
hC.addlisteners(L);
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