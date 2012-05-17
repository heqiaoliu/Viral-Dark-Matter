function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:37 $

XUnits = Constr.getDisplayUnits('XUnits');
YUnits = Constr.getDisplayUnits('YUnits');
Omega  = unitconv(Constr.Omega(Constr.SelectedEdge,:),Constr.OmegaUnits,YUnits);
Sigma  = unitconv(Constr.Sigma(Constr.SelectedEdge,:),Constr.SigmaUnits,XUnits);

switch Context
   case {'move','resize'}
      % Status update when completing move
      if numel(Constr.SelectedEdge) > 1
         Status = sprintf('New requirement location is from %0.3g to %0.3g',...
            min(min(Sigma)),max(max(Sigma)));
         Status = sprintf('%s and from %0.3g to %0.3g.', ...
            Status, min(min(Omega)), max(max(Omega)));
      else
         Status = sprintf('New requirement segment location is from %0.3g to %0.3g',...
            min(Sigma),max(Sigma));
         Status = sprintf('%s and from %0.3g to %0.3g.', ...
            Status, min(Omega), max(Omega));
      end
   case 'hover'
      Type = Constr.Type;  Type(1) = upper(Type(1));
      if numel(Constr.SelectedEdge) > 1
         Description = sprintf('%s limit with real range from %0.3g to %0.3g',Type,...
            min(min(Sigma)),max(max(Sigma)));
         Description = sprintf('%s and imaginary range from %0.3g to %0.3g.', ...
            Description, min(min(Omega)), max(max(Omega)));
      else
         Description = sprintf('%s segment limit with real range from %0.3g to %0.3g',Type,...
            min(Sigma),max(Sigma));
         Description = sprintf('%s and imaginary range from %0.3g to %0.3g.', ...
            Description, min(min(Omega)), max(max(Omega)));
      end
      Status = sprintf('%s\nLeft-click and drag to move this gain requirement.',Description);
   case 'hovermarker'
      % Status when hovering over markers
      Status = sprintf('Select and drag to adjust extent and slope of requirement.');
end
	
	