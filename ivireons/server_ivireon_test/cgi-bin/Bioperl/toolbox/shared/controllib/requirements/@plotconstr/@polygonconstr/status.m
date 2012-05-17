function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:59 $

XUnits = Constr.getDisplayUnits('XUnits');
YUnits = Constr.getDisplayUnits('YUnits');
Y  = unitconv(Constr.yCoords(Constr.SelectedEdge,:),Constr.yUnits,YUnits);
X = unitconv(Constr.xCoords(Constr.SelectedEdge,:),Constr.xUnits,XUnits);

switch Context
case 'move'
   case {'move','resize'}
      % Status update when completing move
      if numel(Constr.SelectedEdge) > 1
         Status = sprintf('New requirement location is from %0.3g to %0.3g %s',...
            min(min(X)),max(max(X)),XUnits);
         Status = sprintf('%s and from %0.3g to %0.3g %s.', ...
            Status, min(min(Y)), max(max(Y)), YUnits);
      else
         Status = sprintf('New requirement segment location is from %0.3g to %0.3g %s',...
            min(X),max(X),XUnits);
         Status = sprintf('%s and from %0.3g to %0.3g %s.', ...
            Status, min(Y), max(Y), YUnits);
      end
case 'hover'
      Type = Constr.Type;  Type(1) = upper(Type(1));
      if numel(Constr.SelectedEdge) > 1
         Description = sprintf('%s limit with real range from %0.3g to %0.3g %s',Type,...
            min(min(X)),max(max(X)),XUnits);
         Description = sprintf('%s and imaginary range from %0.3g to %0.3g %s.', ...
            Description, min(min(Y)), max(max(Y)), YUnits);
      else
         Description = sprintf('%s segment limit with real range from %0.3g to %0.3g %s',Type,...
            min(X),max(X),XUnits);
         Description = sprintf('%s and imaginary range from %0.3g to %0.3g %s.', ...
            Description, min(min(Y)), max(max(Y)), YUnits);
      end
      Status = sprintf('%s\nLeft-click and drag to move this requirement.',Description);
   
case 'hovermarker'
      % Status when hovering over markers
      Status = sprintf('Select and drag to adjust extent and slope of requirement.');
end
