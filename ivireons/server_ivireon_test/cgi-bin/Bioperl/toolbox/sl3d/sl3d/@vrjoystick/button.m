function b = button(joy, n)
%BUTTON Read a joystick button.
%   B = BUTTON(JOY, N) reads the status of joystick button number N.
%   Button status is returned as logical 0 if not pressed and logical 1
%   if pressed.
%   The N parameter can be a vector to return multiple buttons at once.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/05/07 18:29:32 $ $Author: batserve $

% read the specified joystick buttons
try
  [~, b] = joyinput('MLRead', joy);
catch ME
  throwAsCaller(ME);
end

% extract the required elements
if nargin>1
  try
    b = b(n);
  catch ME
    throwAsCaller(MException('VR:joystickerr', 'Joystick button number must be between 1 and %d.', numel(b)));
  end
end
