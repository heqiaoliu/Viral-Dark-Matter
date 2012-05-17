function [PointerType,Status] = hoverstatus(Editor,Status)
%HOVERSTATUS  Sets pointer type and status when hovering editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.23.4.2 $  $Date: 2005/12/22 17:42:03 $

% RE: AXES is the axis on which zoom is occurring

HG = Editor.HG;
SISOfig = double(Editor.Axes.Parent);

% Get handles of movable markers and lines
MovableMarkers = [HG.Compensator.Magnitude;HG.Compensator.Phase];
NWM = strcmp(get(MovableMarkers,{'Tag'}),'NotchWidthMarker');
MovableLine = HG.BodePlot(1);
FixedLines = HG.BodePlot(2:end);
    
% Get currently hovered object
HitObject = hittest(SISOfig);   

% Set pointer and status
if HitObject==MovableLine
    if ~Editor.GainTunable
        PointerType = 'arrow';
        Status = sprintf(['%s For the current configuration of this loop, ', ...
            'the gain is not editable.'], get(HitObject, 'Tag'));
    else
        PointerType = 'hand';
        Status = sprintf('%s\nLeft click and move this curve up or down to adjust the gain of %s.',...
            get(HitObject,'Tag'),lower(Editor.GainTargetBlock.Name));
    end
elseif any(HitObject==FixedLines)
    PointerType = 'arrow';
    Status = sprintf('%s\nRight click for design options.',get(HitObject,'Tag'));  
elseif any(HitObject==MovableMarkers(NWM,:)),
    % Notch width marker is in focus
    PointerType = 'lrdrag';
    Status = sprintf('Left click and move left or right to adjust the notch filter width');
elseif any(HitObject==MovableMarkers(~NWM,:))
    HoverPZVIEW = getappdata(HitObject, 'PZVIEW');
    % Pole or zero in focus
    PointerType = 'hand';
    if strcmp(get(HitObject,'Marker'),'x')
        Status = sprintf('Left click to move this pole of the %s.',HoverPZVIEW.GroupData.Parent.describe(false));
    else
        Status = sprintf('Left click to move this zero of the %s.',HoverPZVIEW.GroupData.Parent.describe(false));
    end
else
    PointerType = 'arrow';
end

