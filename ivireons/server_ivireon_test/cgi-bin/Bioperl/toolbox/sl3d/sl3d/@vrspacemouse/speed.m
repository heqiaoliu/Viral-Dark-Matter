function x = speed(mouse, n)
%SPEED Read a Space Mouse speed axis.
%   S = SPEED(MOUSE, N) reads the speed of Space Mouse axis number N.
%   The N parameter can be a vector to return speeds of multiple axes at once.
%   No transformations are done. Outputs are translation and rotation speeds.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:52 $ $Author: batserve $

% read the specified Space Mouse axes
try
  x = spacemouse('MLRead', getAll(mouse));
catch ME
  throwAsCaller(ME);
end

% extract the required elements
if nargin>1
  try
    x = x(n);
  catch ME
    throwAsCaller(MException('VR:spacemouseerr', 'Space Mouse axis number must be between 1 and %d.', numel(x)));
  end
end
