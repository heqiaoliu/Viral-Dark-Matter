function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:14 $

switch Context
   case 'hover'
      % Status when hovered
      Description = sprintf('Design requirement: damping > %.3g (overshoot < %.3g %s).',...
         Constr.Damping,Constr.overshoot,'%');
      Status = sprintf('%s\nLeft-click and drag to move this requirement.',Description);
   otherwise
      % Status update when completing move
      if strcmpi(Constr.Format,'damping')
         Status = sprintf('Requires damping of at least %0.3g.',Constr.Damping);
      else
         Status = sprintf('Requires overshoot of at most %0.3g %s.',Constr.overshoot,'%');
      end
end
	
	