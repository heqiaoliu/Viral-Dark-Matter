function customizeConstr(this,hC) 
% CUSTOMIZECONSTR customize the requirement for this visualization
%
% customizeConstr(this,hC)
%
% Inputs:
%   hC - handle to plotconstr.designconstr object
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:51 $

%Set the requirement patch color based on enabled state of bounds
hBlk = this.Application.DataSource.BlockHandle;
hReq = hC.getRequirementObject;
if isa(hReq,'srorequirement.gainphasemargin') && strcmp(hBlk.EnableMargins,'on')
   PatchColor = this.hPlot.Options.RequirementColor;
else
   PatchColor = this.hPlot.Options.DisabledRequirementColor;
end
if strcmp(this.PlotType,'nyquist')
   set(hC,'PatchColor',PatchColor,'ZLevel',10);
else
   set(hC,'PatchColor',PatchColor,'ZLevel',-2);
end

%Set constraint display units and create listeners for axes unit changes
switch this.PlotType
   case 'bode'
      hC.setDisplayUnits('xunits',this.hPlot.Axes.YUnits{2}); %Phase
      hC.setDisplayUnits('yunits',this.hPlot.Axes.YUnits{1}); %Gain
      pu = this.hPlot.Axes.findprop('YUnits');
   case 'nichols'
      hC.setDisplayUnits('xunits',this.hPlot.Axes.XUnits);
      hC.setDisplayUnits('yunits',this.hPlot.Axes.YUnits);
      pu = [this.hPlot.Axes.findprop('XUnits');this.hPlot.Axes.findprop('YUnits')];
   case 'nyquist'
      %Axes units are Re & Im, use units defined by block.
      hC.setDisplayUnits('xunits', hBlk.PhaseUnits);
      hC.setDisplayUnits('yunits', hBlk.MagnitudeUnits);
      pu = [];
end

if ~isempty(pu)
   L = handle.listener(this.hPlot.Axes,pu,'PropertyPostSet', {@LocalSetUnits, hC, this.PlotType});
   hC.addlisteners(L);
end
end

function LocalSetUnits(eventSrc,eventData,hC,PlotType)
% Syncs constraint props with related Editor props

whichUnits = lower(eventSrc.Name);
NewValue   = eventData.NewValue;
switch PlotType
   case 'bode'
      if strcmp(whichUnits,'yunits')
         hC.setDisplayUnits('xunits',NewValue{2}); %Phase
         hC.TextEditor.setDisplayUnits('xunits',NewValue{2});
         hC.setDisplayUnits('yunits',NewValue{1}); %Gain
         hC.TextEditor.setDisplayUnits('yunits',NewValue{1});
      end
   case 'nichols'
      hC.setDisplayUnits(whichUnits,NewValue);
      hC.TextEditor.setDisplayUnits(whichUnits,NewValue);
end

% Update constraint display (and notify observers)
update(hC)
end