function p = pov(joy, n)
%POV Read a joystick point of view.
%   P = POV(JOY, N) reads the status of joystick POV (Point Of View) 
%   control number N.
%   Point Of View is usually returned in degrees, with -1 meaning
%   "not selected".
%   The N parameter can be a vector to return multiple POVs at once.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/05/07 18:29:33 $ $Author: batserve $

% read the specified joystick POVs
try
  [~, ~, p] = joyinput('MLRead', joy);
catch ME
  throwAsCaller(ME);
end

% extract the required elements
if nargin>1
  try
    p = p(n);
  catch ME
    throwAsCaller(MException('VR:joystickerr', 'Joystick POV number must be between 1 and %d.', numel(p)));
  end
end
