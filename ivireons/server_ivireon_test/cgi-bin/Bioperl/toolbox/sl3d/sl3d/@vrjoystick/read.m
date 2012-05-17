function [axes, buttons, povs] = read(joy, force)
%READ Read the complete joystick status.
%   [AXES, BUTTONS, POVS] = READ(JOY) reads status of axes, buttons
%   and POVs (Point Of View controls) of the specified joystick.
%
%   [AXES, BUTTONS, POVS] = READ(JOY, FORCES) in addition applies feedback
%   forces to a force-feedback joystick.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:30 $ $Author: batserve $

% read the joystick status
try
  if nargin<=1
    [axes, buttons, povs] = joyinput('MLRead', joy);
  else
    % pad forces with zeros before sending to joyinput
    [axes, buttons, povs] = joyinput('MLRead', joy, double([force zeros(1,joy.PrivateIWork(4)-numel(force))]));
  end
catch ME
  throwAsCaller(ME);
end
