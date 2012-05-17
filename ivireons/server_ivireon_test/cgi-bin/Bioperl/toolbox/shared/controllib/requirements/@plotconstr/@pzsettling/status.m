function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:50 $

switch Context
   case 'hover'
      % Status when hovered
      Description = sprintf('Design requirement: settling time < %.3g sec.',Constr.SettlingTime);
      Status = sprintf('%s\nLeft-click and drag to change settling time value.',Description);
   otherwise
      % Status update when completing move
      Status = sprintf('Settling time required to be at most %0.3g seconds.',...
         Constr.SettlingTime);
end
	
	