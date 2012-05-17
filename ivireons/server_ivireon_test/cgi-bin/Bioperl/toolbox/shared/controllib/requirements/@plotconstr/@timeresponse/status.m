function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:34:09 $

XUnits = Constr.getDisplayUnits('XUnits');
YUnits = Constr.getDisplayUnits('YUnits');
Mag  = unitconv(Constr.Magnitude(Constr.SelectedEdge,:),Constr.MagnitudeUnits,YUnits);
Time = unitconv(Constr.Time(Constr.SelectedEdge,:),Constr.TimeUnits,XUnits);

switch Context
   case {'move','resize'}
      % Status update when completing move
      if numel(Constr.SelectedEdge) > 1
         Status = sprintf('New requirement location is from %0.3g to %0.3g %s',...
            min(min(Time)),max(max(Time)),XUnits);
         Status = sprintf('%s and from %0.3g to %0.3g.', ...
            Status, min(min(Mag)), max(max(Mag)));
      else
         Status = sprintf('New requirement segment location is from %0.3g to %0.3g %s',...
            min(Time),max(Time),XUnits);
         Status = sprintf('%s and from %0.3g to %0.3g.', ...
            Status, min(Mag), max(Mag));
      end
   case 'hover'
      Type = Constr.Type;  Type(1) = upper(Type(1));
      if numel(Constr.SelectedEdge) > 1
         Description = sprintf('%s limit with time range from %0.3g to %0.3g %s',Type,...
            min(min(Time)),max(max(Time)),XUnits);
         Description = sprintf('%s and magnitude range from %0.3g to %0.3g.', ...
            Description, min(min(Mag)), max(max(Mag)));
      else
         Description = sprintf('%s segment limit with time range from %0.3g to %0.3g %s',Type,...
            min(Time),max(Time),XUnits);
         Description = sprintf('%s and magnitude range from %0.3g to %0.3g.', ...
            Description, min(min(Mag)), max(max(Mag)));
      end
      Status = sprintf('%s\nLeft-click and drag to move this requirement.',Description);
   case 'hovermarker'
      % Status when hovering over markers
      Status = sprintf('Select and drag to adjust extent and slope of requirement.');
end
	
	