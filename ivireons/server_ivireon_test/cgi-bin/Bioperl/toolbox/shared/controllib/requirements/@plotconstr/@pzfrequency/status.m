function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:29 $

f = unitconv(Constr.Frequency,Constr.getData('xUnits'),Constr.getDisplayUnits('xUnits'));

switch Context
   case 'hover'
      % Status when hovered
      if strcmpi(Constr.Type,'upper')
         lgt = '<';
      else
         lgt = '>';
      end
      Description = sprintf('Design requirement: natural frequency %s %.3g %s.',...
         lgt,f,Constr.FrequencyUnits);
      Status = sprintf('%s\nLeft-click and drag to change natural frequency value.',Description);
   otherwise
      % Status update when completing move
      if strcmpi(Constr.Type,'upper')
         lgt = 'most';
      else
         lgt = 'least';
      end
      Status = sprintf('Natural frequency required to be at %s %0.3g %s.',...
         lgt,f,Constr.getDisplayUnits('xUnits'));
end

	