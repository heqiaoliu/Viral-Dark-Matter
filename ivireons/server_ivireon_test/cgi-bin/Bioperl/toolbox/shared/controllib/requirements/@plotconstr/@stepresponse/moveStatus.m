function str = moveStatus(this) 
% MOVESTATUS mehod to return string for status display during move
% operation
%
 
% Author(s): A. Stothert 10-Mar-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:01 $

%Update step characteristics
StepChar = this.Requirement.getStepCharacteristics;

%Construct string based on edge moved
iEdge = this.SelectedEdge;
if numel(iEdge) == 1
   switch iEdge
      case 1
         str = sprintf('Percentage overshoot: %g%%, Settling time: %g sec', ...
            StepChar.PercentOvershoot, ...
            StepChar.SettlingTime);
      case {2,5}
         str = sprintf('Percentage settling: %g%%, Settling time: %g sec', ...
            StepChar.PercentSettling, ...
            StepChar.SettlingTime);
      case 3
         str = sprintf('Percentage undershoot: %g%%, Rise time: %g sec', ...
            StepChar.PercentUndershoot, ...
            StepChar.RiseTime);
      case 4
         str = sprintf('Percentage rise: %g%%, Rise time: %g sec, Settling time: %g sec', ...
            StepChar.PercentRise, ...
            StepChar.RiseTime, ...
            StepChar.SettlingTime);
   end
else
   str = '';
end
