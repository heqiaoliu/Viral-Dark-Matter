function x = position(mouse, n)
%POSITION Read a Space Mouse position axis.
%   P = POSITION(MOUSE, N) reads the position of Space Mouse axis number N.
%   The N parameter can be a vector to return positions of multiple axes at once.
%   Translations and rotations are integrated. Outputs are position 
%   and orientation in the form of roll/pitch/yaw angles.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:51 $ $Author: batserve $

% read the specified Space Mouse axes
try
  x = spacemouse('MLRead', getAll(mouse), 'POSITION');
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
