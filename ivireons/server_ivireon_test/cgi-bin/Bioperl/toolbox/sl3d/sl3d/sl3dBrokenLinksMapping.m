function mapOldMaskToCurrent = sl3dBrokenLinksMapping()
% Broken links restoration mapping for Simulink 3D Animation blocks.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/01/19 03:06:06 $ $Author: batserve $

% return list of potentially broken links that need to be re-established

mapOldMaskToCurrent = { ...
...
...  % Main library
...
'Joystick Input', ...
   'Joystick Input', ...
   'S-Function', ...
   'vrlib/Joystick Input', ...
   { ...
      'joyid'; ...
      'adjustports'; ...
      'forcefeed'; ...
   }, ...
   'joyinput'; ...
'Space Mouse Input', ...
   'Space Mouse Input', ...
   'S-Function', ...
   'vrlib/Space Mouse Input', ...
   { ...
      'Port'; ...
      'OutputType'; ...
      'Dominant'; ...
      'DisableTranslation'; ...
      'DisableRotation'; ...
      'NormalizeAngle'; ...
      'EnableLimit'; ...
      'PositionSensitivity'; ...
      'RotationSensitivity'; ...
      'InitialPosition'; ...
      'InitialRotation'; ...
      'PositionLow'; ...
      'PositionUp'; ...
   }, ...
   'spacemouse'; ...
'Magellan Space Mouse', ...
   'Space Mouse Input', ...
   'S-Function', ...
   'vrlib/Space Mouse Input', ...
   { ...
      'Port'; ...
      'OutputType'; ...
      'Dominant'; ...
      'DisableTranslation'; ...
      'DisableRotation'; ...
      'NormalizeAngle'; ...
      'EnableLimit'; ...
      'PositionSensitivity'; ...
      'RotationSensitivity'; ...
      'InitialPosition'; ...
      'InitialRotation'; ...
      'PositionLow'; ...
      'PositionUp'; ...
   }, ...
   'spacemouse'; ...
'VR Placeholder', ...
   'VR Placeholder', ...
   'SubSystem', ...
   'vrlib/VR Placeholder', ...
   { ...
      'outwidth'; ...
   }, ...
   ''; ...
'VR Signal Expander', ...
   'VR Signal Expander', ...
   'SubSystem', ...
   'vrlib/VR Signal Expander', ...
   { ...
      'outwidth'; ...
      'outidx'; ...
   }, ...
   ''; ...
'Virtual Reality Sink', ...
   'Virtual Reality Sink', ...
   'S-Function', ...
   'vrlib/VR Sink', ...
   { ...
      'SampleTime'; ...
      'ViewEnable'; ...
      'RemoteChange'; ...
      'RemoteView'; ...
      'FieldsWritten'; ...
      'WorldFileName'; ...
      'WorldDescription'; ...
      'AutoView'; ...
      'VideoDimensions'; ...
      'FigureProperties'; ...
   }, ...
   'vrsfunc'; ...
'VR Text Output', ...
   'VR Text Output', ...
   'M-S-Function', ...
   'vrlib/VR Text Output', ...
   { ...
      'VrmlFile'; ...
      'TxtNode'; ...
      'FormatString'; ...
      'ForceViewerOpen'; ...
   }, ...
   'vrtxtout'; ...
'Virtual Reality Sink', ...
   'Virtual Reality Sink', ...
   'S-Function', ...
   'vrlib/VR To Video', ...
   { ...
      'SampleTime'; ...
      'ViewEnable'; ...
      'RemoteChange'; ...
      'RemoteView'; ...
      'FieldsWritten'; ...
      'WorldFileName'; ...
      'WorldDescription'; ...
      'AutoView'; ...
      'VideoDimensions'; ...
      'FigureProperties'; ...
   }, ...
   'vrsfunc'; ...
...
...  % Utilities library
...
'Cross Product', ...
   'Cross Product', ...
   'SubSystem', ...
   'vrlib/Utilities/Cross Product', ...
   { ...
   }, ...
   ''; ...
'Normalize Vector', ...
   'Normalize Vector', ...
   'SubSystem', ...
   'vrlib/Utilities/Normalize Vector', ...
   { ...
      'maxzero'; ...
   }, ...
   ''; ...
'Rotation Between 2 Vectors', ...
   'Rotation Between 2 Vectors', ...
   'SubSystem', ...
   'vrlib/Utilities/Rotation Between\n2 Vectors', ...
   { ...
   }, ...
   ''; ...
'Rotation Matrix to VRML Rotation', ...
   'Rotation Matrix to VRML Rotation', ...
   'SubSystem', ...
   'vrlib/Utilities/Rotation Matrix\nto VRML Rotation', ...
   { ...
      'maxzero'; ...
   }, ...
   ''; ...
'Viewpoint Direction to VRML Orientation', ...
   'Viewpoint Direction to VRML Orientation', ...
   'SubSystem', ...
   'vrlib/Utilities/Viewpoint Direction\nto VRML Orientation', ...
   { ...
   }, ...
   ''; ...
};

mapOldMaskToCurrent = cell2struct( mapOldMaskToCurrent, { 'oldMaskType','newMaskType','newBlockType','newRefBlock', 'MaskNames', 'SFunctionName' }, 2);