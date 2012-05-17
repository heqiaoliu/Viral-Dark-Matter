function joy = vrjoystick(id, force)
%VRJOYSTICK Create a joystick object.
%   JOY = VRJOYSTICK(ID) creates a joystick object capable of interfacing
%   a joystick device. The ID parameter is one-based joystick ID.
%
%   JOY = VRJOYSTICK(ID, 'forcefeedback') enables force-feedback if the
%   joystick supports this capability.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:31 $ $Author: batserve $

% create the joystick structure
try
  joy = joyinput('MLOpen', id, nargin>1 && strcmpi(force, 'forcefeedback'));
catch ME
  throwAsCaller(ME);
end

% change it to vrjoystick object
joy = class(joy, 'vrjoystick');
