function [PointerType, Status] = hoverstatus(Editor, Status)
%HOVERSTATUS  Sets pointer type and status when hovering editor.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $ $Date: 2005/12/22 17:42:38 $

% Get handle
HG = Editor.HG;
PlotAxes = getaxes(Editor.Axes);
SISOfig = PlotAxes.Parent;

% Get handles of movable markers and lines
MovableMarkers = [HG.Compensator];
NWM = strcmp(get(MovableMarkers, {'Tag'}), 'NotchWidthMarker');
MovableLine = HG.NicholsPlot;
FixedLines = HG.NicholsPlot(2:end);

% Get currently hovered object
HitObject = hittest(SISOfig);   

% Set pointer and status
if HitObject == MovableLine
   % Nichols plot in focus
   if ~Editor.GainTunable
       PointerType = 'arrow';
       Status = sprintf(['%s For the current configuration of this loop, ', ...
           'the gain is not editable.\n%s.'], get(HitObject, 'Tag'), ...
           Editor.pointerlocation);
   else
       PointerType = 'hand';
       Status = sprintf(['%s Left click and move this curve up or down ', ...
           'to adjust the loop gain.\n%s.'], get(HitObject, 'Tag'), ...
           Editor.pointerlocation);
   end
elseif any(HitObject == FixedLines)
   PointerType = 'arrow';
   Status = sprintf('%s\nRight click for design options.', ...
      get(HitObject, 'Tag'));
   
elseif any(HitObject == MovableMarkers(NWM, :)),
   % Notch width marker is in focus
   PointerType = 'lrdrag';
   Status = sprintf('Left click to adjust the notch filter width.');
   
elseif any(HitObject == MovableMarkers(~NWM, :))
   % Pole or zero in focus
   PointerType = 'hand';
   HoverPZVIEW = getappdata(HitObject, 'PZVIEW');
   if strcmp(get(HitObject, 'Marker'), 'x')
      Status = sprintf('Left click to move this pole of the %s.', ...
         HoverPZVIEW.GroupData.Parent.describe(false));
   else
      Status = sprintf('Left click to move this zero of the %s.', ...
         HoverPZVIEW.GroupData.Parent.describe(false));
   end
   
else
   PointerType = 'arrow';
end
