function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:19 $

XUnits = Constr.getDisplayUnits('XUnits');
YUnits = Constr.getDisplayUnits('YUnits');
Phase  = unitconv(Constr.OLPhase(Constr.SelectedEdge,:),Constr.PhaseUnits,XUnits);
Mag    = unitconv(Constr.OLGain(Constr.SelectedEdge,:),Constr.MagnitudeUnits,YUnits);

switch Context
   case {'move','resize'}
      % Status update when completing move
      if numel(Constr.SelectedEdge) > 1
         Status = sprintf('New Gain-Phase requirement location is from %0.3g to %0.3g %s',...
            min(min(Phase)),max(max(Phase)),XUnits);
         Status = sprintf('%s and from %0.3g to %0.3g %s.', ...
            Status, min(min(Mag)), max(max(Mag)), YUnits);
      else
         Status = sprintf('New Gain-Phase requirement segment location is from %0.3g to %0.3g %s',...
            min(Phase),max(Phase),XUnits);
         Status = sprintf('%s and from %0.3g to %0.3g %s.', ...
            Status, min(Mag), max(Mag), YUnits);
      end
   case 'hover'
      % Status when hovered
      Type = Constr.Type;  Type(1) = upper(Type(1));
      if numel(Constr.SelectedEdge) > 1
         Description = sprintf('%s Gain-Phase limit with phase range from %0.3g to %0.3g %s',Type,...
            min(min(Phase)),max(max(Phase)),XUnits);
         Description = sprintf('%s and magnitude range from %0.3g to %0.3g %s.', ...
            Description, min(min(Mag)), max(max(Mag)), YUnits);
      else
         Description = sprintf('%s Gain-Phase segment limit with phase range from %0.3g to %0.3g %s',Type,...
            min(Phase),max(Phase),XUnits);
         Description = sprintf('%s and magnitude range from %0.3g to %0.3g %s.', ...
            Description, min(min(Mag)), max(max(Mag)), YUnits);
      end
      Status = sprintf('%s\nLeft-click and drag to move this gain requirement.',Description);

   case 'hovermarker'
      % Status when hovering over markers
      Status = sprintf('Select and drag to adjust extent and slope of requirement segment.');
end
	
	