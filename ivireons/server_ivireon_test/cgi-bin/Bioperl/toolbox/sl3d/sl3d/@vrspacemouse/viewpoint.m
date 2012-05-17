function x = viewpoint(mouse)
%VIEWPOINT Read Space Mouse coordinates in VRML viewpoint format.
%   P = VIEWPOINT(MOUSE) reads the Space Mouse coordinates in VRML viewpoint format.
%   Translations and rotations are integrated. Outputs are position and orientation
%   in the form of an axis and an angle. You can use these values as viewpoint 
%   coordinates in VRML.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:54 $ $Author: batserve $

% read the specified Space Mouse axes
try
  x = spacemouse('MLRead', getAll(mouse), 'VIEWPOINT');
catch ME
  throwAsCaller(ME);
end
