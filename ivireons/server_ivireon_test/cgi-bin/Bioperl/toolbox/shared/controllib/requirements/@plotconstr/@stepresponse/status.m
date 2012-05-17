function Status = status(this,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:34:05 $

switch Context
   case {'move','resize'}
      % Status update when completing move
      Status = sprintf('Rise time: %g sec, Settling time: %g sec, Percentage overshoot: %g %%, Percentage settling: %g %%', ...
         this.StepChar.RiseTime, ...
         this.StepChar.SettlingTime, ...
         this.StepChar.PercentOvershoot, ...
         this.StepChar.PercentSettling);
   case 'hover'
      Status = sprintf('Rise time: %g sec, Settling time: %g sec, Percentage overshoot: %g %%, Percentage settling: %g %%', ...
         this.StepChar.RiseTime, ...
         this.StepChar.SettlingTime, ...
         this.StepChar.PercentOvershoot, ...
         this.StepChar.PercentSettling);
      Status = sprintf('%s\nLeft-click and drag to move this requirement.',Status);
   case 'hovermarker'
      % Status when hovering over markers
      Status = sprintf('Select and drag to adjust extent and slope of requirement.');
end
	
	