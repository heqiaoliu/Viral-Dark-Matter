function a = axis(joy, n)
%AXIS Read a joystick axis.
%   A = AXIS(JOY, N) reads the status of joystick axis number N.
%   Axis status is returned in the range from -1 to 1.
%   The N parameter can be a vector to return multiple axes at once.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:24 $ $Author: batserve $

% read the specified joystick axes
try
  a = joyinput('MLRead', joy);
catch ME
  throwAsCaller(ME);
end

% extract the required elements
if nargin>1
  try
    a = a(n);
  catch ME
    throwAsCaller(MException('VR:joystickerr', 'Joystick axis number must be between 1 and %d.', numel(a)));
  end
end
