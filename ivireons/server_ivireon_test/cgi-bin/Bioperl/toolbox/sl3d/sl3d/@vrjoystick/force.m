function force(joy, n, f)
%FORCE Apply force feedback to joystick.
%   FORCE(JOY, N, F) applies force feedback to joystick axis N.
%   The N parameter can be a vector to affect multiple axes at once.
%   The F parameter values should be in range from -1 to 1. The number of
%   elements of F should either match the number of elements of N, or
%   F can be a scalar to be applied to all the axes specified by N.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1.8.1 $ $Date: 2010/07/23 15:44:53 $ $Author: batserve $

% test for force-feedback support
nforce = joy.PrivateIWork(4);
if nforce<=0
  throwAsCaller(MException('VR:joystickerr', 'Force feedback is disabled or not supported.'));
end
if any(n>nforce)
  throwAsCaller(MException('VR:joystickerr', 'Joystick force-feedback axis number must be between 1 and %d.', nforce));
end

% scalar-expand the force parameter
force = zeros(1, nforce);
try
  force(n) = f;
catch ME
  throwAsCaller(MException('VR:joystickerr', 'Number of forces must either match the number of axes or be a scalar.'));
end

% affect the specified joystick axes
try
  joyinput('MLRead', joy, force);
catch ME
  throwAsCaller(ME);
end
