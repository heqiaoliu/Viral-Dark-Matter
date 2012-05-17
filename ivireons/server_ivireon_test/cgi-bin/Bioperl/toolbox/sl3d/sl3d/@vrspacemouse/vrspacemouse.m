classdef vrspacemouse < hgsetget
%VRSPACEMOUSE Create a Space Mouse object.
%   MOUSE = VRSPACEMOUSE(ID) creates a Space Mouse object capable of
%   interfacing a Space Mouse device. The ID parameter is a string that
%   describes Space Mouse connection: COM1, COM2, COM3, COM4, USB1, USB2,
%   USB3, or USB4.
%
%   The VRSPACEMOUSE object has several properties that influence the behavior
%   of the Space Mouse device. The properties can be read or modified either
%   using dot notation or using GET and SET. These commands are all valid:
%
%   mouse.DominantMode = true
%   mouse.DominantMode
%   set(mouse, 'DominantMode', false)
%   get(mouse, 'DominantMode')
%
%
%   Valid properties are (property names are case-sensitive):
%
%     'PositionSensitivity' (settable)
%        Mouse sensitivity for translations. Higher values correspond to higher sensitivity.
%
%     'RotationSensitivity' (settable)
%        Mouse sensitivity for rotations. Higher values correspond to higher sensitivity.
%
%     'DisableRotation' (settable)
%        Fixes the rotations at initial values, allowing you to change positions only.
%
%     'DisableTranslation' (settable)
%        Fixes the positions at the initial values, allowing you to change rotations only.
%
%     'DominantMode' (settable)
%        If this property is true, the mouse accepts only the prevailing movement
%        and rotation and ignores the others. This mode is very useful for beginners
%        using the Magellan Space Mouse.
%
%     'LimitPosition' (settable)
%        Enables mouse position limits. If false, UpperPositionLimit and LowerPositionLimit 
%        are ignored.
%  
%     'UpperPositionLimit' (settable)
%        Position coordinates for the upper limit of the mouse.
%
%     'LowerPositionLimit' (settable)
%        Position coordinates for the lower limit of the mouse.
%
%     'NormalizeOutputAngle' (settable)
%        Determines whether the integrated rotation angles should wrap on a full circle (360°)
%        or not. This is not used when you read the Output Type as Speed.
%
%     'InitialPosition' (settable)
%        Initial condition for integrated translations. This is not used when you set the Output 
%        Type to Speed.
%
%     'InitialRotation' (settable)
%        Initial condition for integrated rotations. This is not used when you set the Output 
%        Type to Speed.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:55 $ $Author: batserve $


%%%%%%%%%%%%%%%%%%
%% PROPERTIES
%%%%%%%%%%%%%%%%%%

properties
  DominantMode@logical = false;
  DisableTranslation@logical = false;
  DisableRotation@logical = false;
  NormalizeOutputAngle@logical = false;
  LimitPosition@logical = false;
  PositionSensitivity@double = 0.001;
  RotationSensitivity@double = 0.001;
  InitialPosition@double = [0 0 0];
  InitialRotation@double = [0 0 0];
  UpperPositionLimit@double = [1000 1000 1000];
  LowerPositionLimit@double = [-1000 -1000 -1000];
end


properties(Access = 'private', Hidden = true)
  Id;
  PrivateIWork;
  PrivatePWork;
  PrivateRWork;
end



%%%%%%%%%%%%%%%%%%
%% METHODS
%%%%%%%%%%%%%%%%%%

methods

% Property setters
function obj = set.DominantMode(obj, y)
  obj.DominantMode = y;
  spacemouse('MLProperty', getAll(obj), 'DominantMode');
end

function obj = set.DisableTranslation(obj, y)
  obj.DisableTranslation = y;
  spacemouse('MLProperty', getAll(obj), 'DisableTranslation');
end

function obj = set.DisableRotation(obj, y)
  obj.DisableRotation = y;
  spacemouse('MLProperty', getAll(obj), 'DisableRotation');
end

function obj = set.InitialPosition(obj, y)
  obj.InitialPosition = y;
  spacemouse('MLProperty', getAll(obj), 'InitialPosition');
end

function obj = set.InitialRotation(obj, y)
  obj.InitialRotation = y;
  spacemouse('MLProperty', getAll(obj), 'InitialRotation');
end


% Constructor.
function obj = vrspacemouse(id)

  % create the Space Mouse structure
  try
    mouse = spacemouse('MLOpen', id);
  catch ME
    throwAsCaller(ME);
  end

  % copy structure fields to object private properties
  for f=fieldnames(mouse)'
    obj.(f{1}) = mouse.(f{1});
  end

  % update driver property values - calling these two is enough to update them all
  spacemouse('MLProperty', getAll(obj), 'DominantMode');
  spacemouse('MLProperty', getAll(obj), 'InitialPosition');
end


end % of methods


%%%%%%%%%%%%%%%%%%%%%
%% PRIVATE METHODS
%%%%%%%%%%%%%%%%%%%%%
methods(Access = 'private')

  function value = getAll(obj)
    value = get(obj);
    value.Id = obj.Id;
    value.PrivateIWork = obj.PrivateIWork;
    value.PrivatePWork = obj.PrivatePWork;
    value.PrivateRWork = obj.PrivateRWork;
  end

end % of private methods


end % of classdef
