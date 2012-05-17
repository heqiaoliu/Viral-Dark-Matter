%% Plane Manipulation Using Space Mouse MATLAB(R) Object
% This demonstration shows how to use the Space Mouse via MATLAB(R) interface.
%
% After starting this demo, a virtual scene with an aircraft is displayed
% in the Simulink(R) 3D Animation(TM) Viewer. You can navigate the plane in 
% the scene using the Space Mouse. By pressing the device button 1 you can
% place a marker at the current plane position.
%
% This demonstration requires a Space Mouse or other compatible device.

% Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/11/07 21:30:01 $ $Author: batserve $

%% Create and Initialize the Space Mouse Object
%
% The device ID is set to USB1 in the example. If your device uses a
% different connection, set the ID accordingly. 
% Valid values for the space mouse ID are: 
%
%   COM1, COM2, COM3, COM4, USB1, USB2, USB3 or USB4.
%
% NOTE: a warning message is printed if Space Mouse is not connected.

ID = 'USB1';
MOUSE = [];
try
  % try to create the space mouse object
  MOUSE = vrspacemouse(ID);
catch ME
  fprintf('Unable to initialize the Space Mouse on port %s.\n', ID);
end

%% Load and View the Virtual World

% create and open the vrworld object
w = vrworld('vrtkoff_hud.wrl', 'new');
open(w);

% create the vrfigure showing the virtual scene
fig = vrfigure(w);
% go to a viewpoint suitable for user navigation
set(fig, 'Viewpoint', 'Ride on the Plane');

% get the manipulated airplane node
airpln = vrnode(w, 'Plane');
% read plane initial translation and rotation
originalTranslation = airpln.translation; 
originalRotation = airpln.rotation;

% set the HUD display text
offset = vrnode(w, 'HUDOffset');
offset.translation = offset.translation + [-0.15 1.9 0];
hudtext = vrnode(w, 'HUDText1');
hudstr = sprintf(strcat('Press button ''1'' to drop a marker\n', ...
  'Press button ''2'' to reset plane position \n Press buttons ''1'' and ''2'' to exit\n'));
hudstr = textscan(hudstr, '%s', 'delimiter', '\n');
hudtext.string = hudstr{1};

%% Add an EXTERNPROTO for Trajectory Markers
% Load a tetrahedron shape PROTO from VRML file containing various marker shapes.

% get the path to the wrl file with marker PROTOs 
pathtomarkers = which('vr_markers.wrl');
% use the tetrahedron shape                                              
MarkerName = 'Marker_Tetrahedron';
% create an EXTERNPROTO with specified marker
try
  addexternproto(w, pathtomarkers, MarkerName);
catch ME
  % if required PROTO is already contained don't throw an exception
  if ~strcmpi(ME.identifier, 'VR:protoexists')
    throwAsCaller(ME);
  end
end

%% Navigation in the Scene
% The interactive navigation is finished either by pressing Space Mouse 
% buttons 1 and 2 simultaneously or by closing the Simulink 3D Animation Viewer figure.

if ~isempty(MOUSE)

  % iterator that ensures unique DEF names for created markers
  iterforname = 0;
  
  % set the mouse sensitivity for translations
  % higher values correspond to higher sensitivity
  MOUSE.PositionSensitivity = 1e-2;
  % set the mouse sensitivity for rotations
  % higher values correspond to higher sensitivity
  MOUSE.RotationSensitivity = 1e-5;
  
  % read the space mouse values and update the scene objects in a cycle
  % repeat unless buttons '1' and '2' simultaneously pressed or figure closed
  while any(button(MOUSE, [1 2]) == 0) && isvalid(fig)
     pause(0.01); 
     % use the method vrspacemouse/viewpoint to get the current translation and rotation
     V = viewpoint(MOUSE);
     % set the new translation to the aircraft node
     airpln.translation = originalTranslation + [-1 1 -1].*V(1:3);
     % set the new rotation to the aircraft node
     airpln.rotation = [-1 1 -1 1].*V(4:7);
     if button(MOUSE, 1) == 1
       % if mouse button '1' pressed create a new marker
       newMarker = vrnode(w, sprintf('%s_%d', 'Marker', iterforname), MarkerName);
       % set marker translation
       newMarker.markerTranslation = originalTranslation + [-1 1 -1].*V(1:3);
       % increment the iterator
       iterforname = iterforname + 1;
     end
     if button(MOUSE, 2) == 1
       % if mouse button '2' pressed reset the plane position and rotation
       airpln.translation = originalTranslation;
       airpln.rotation = originalRotation;
       MOUSE.InitialPosition = [0 0 0];
       MOUSE.InitialRotation = [0 0 0];
     end
     % redraw the virtual scene
     vrdrawnow
  end
end

%% Cleanup

% close the vrfigure
close(fig);
% close the vrworld
close(w);
% clear all used variables
clear ID MOUSE w fig airpln originalTranslation originalRotation offset hudtext hudstr ...
      pathtomarkers MarkerName iterforname V newMarker img_capture img;

% display the end of demo message
displayEndOfDemoMessage(mfilename)
