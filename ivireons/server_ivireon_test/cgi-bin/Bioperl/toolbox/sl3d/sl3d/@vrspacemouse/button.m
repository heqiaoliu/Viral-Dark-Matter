function b = button(mouse, n)
%BUTTON Read a Space Mouse button.
%   B = BUTTON(MOUSE, N) reads the status of Space Mouse button number N.
%   Button status is returned as logical 0 if not pressed and logical 1
%   if pressed.
%   The N parameter can be a vector to return multiple buttons at once.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:48 $ $Author: batserve $

% read the specified Space Mouse buttons
try
  b = spacemouse('MLRead', getAll(mouse), 'BUTTONS');
catch ME
  throwAsCaller(ME);
end

% extract the required elements
if nargin>1
  try
    b = b(n);
  catch ME
    throwAsCaller(MException('VR:spacemouseerr', 'Space Mouse button number must be between 1 and %d.', numel(b)));
  end
end
