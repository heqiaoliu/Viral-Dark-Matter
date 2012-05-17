function [PointerType,Status] = hoverstatus(Editor,Status)
%HOVERSTATUS  Sets pointer type and status when hovering editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.21.4.2 $  $Date: 2005/12/22 17:43:11 $
HG = Editor.HG;
SISOfig = double(Editor.Axes.Parent);
MovableHandles = [HG.ClosedLoop ; HG.Compensator];

% Get currently hovered object
HitObject = hittest(SISOfig);   

if any(HitObject==MovableHandles)
    % Movable object is in focus
    PointerType = 'hand';
    % Give informative status
    HoverPZVIEW = getappdata(HitObject, 'PZVIEW');
    if any(HitObject==HG.ClosedLoop)
        if ~Editor.GainTunable
            PointerType = 'arrow';
            Status = sprintf('The open-loop gain can not be adjusted for the current loop configuration.');
        else
            Status = sprintf('Left-click and move this closed-loop pole to adjust the loop gain.');
        end
    elseif strcmp(get(HitObject,'Marker'),'x')
        Status = sprintf('Left-click to move this pole of the %s.', ...
            HoverPZVIEW.GroupData.Parent.describe(false));
    else
        Status = sprintf('Left-click to move this zero of the %s.', ...
            HoverPZVIEW.GroupData.Parent.describe(false));
    end
else
    PointerType = 'arrow';
    % If close to the locus, hint at selectgain feature
    if any(HitObject==HG.Locus) && Editor.GainTunable
        Status = sprintf('Root locus.  Left-click to move closed-loop pole to this location.');
    end
end
