function str = resizeStatus(this)
% RESIZESTATUS mehod to return string for status displya during move
% operation
%
 
% Author(s): A. Stothert 10-Mar-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:03 $

%Update step characteristics
StepChar = this.Requirement.getStepCharacteristics;

%Construct string based on edge moved
iEdge = this.SelectedEdge;
switch iEdge
   case {1,2,5}
      str = sprintf('Settling time: %g sec', StepChar.SettlingTime);
   case 3
      str = sprintf('Rise time: %g sec', StepChar.RiseTime);
   case 4
      str = sprintf('Rise time: %g sec, Settling time: %g sec', ...
         StepChar.RiseTime,...
         StepChar.SettlingTime);
end