function updateAxesWidth(this)
%UDPDATEAXESWIDTH Update the axes with based on plot type
%   If a 3D figure is rendered, the axes labels may be out of bound.  The make
%   sure that the labels are not overwritten, this function reduces the axes
%   width.  If a 2D figure is rendered, then the axes width is restored to the
%   original size.

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:22 $

% Get the handles
handles = this.WidgetHandles;

% Get active eye diagram object
activeEyeObj = getSelected(this.EyeDiagramObjMgr);
if isempty(activeEyeObj)
    noObject = 1;
    opMode = 'Real Signal';
else
    noObject = 0;
    hEye = activeEyeObj.Handle;
    opMode = get(hEye, 'OperationMode');
end

% Make sure that if the axes is 3D, it is resized
sz = guiSizes(this);
if ~noObject && strcmp(hEye.PlotType, '3D Color')
    if strcmp(opMode, 'Real Signal')
        pos = get(handles.InPhaseAxes, 'Position');
        pos(3) = sz.AxesWidth * 0.95;
        set(handles.InPhaseAxes, 'Position', pos);
    elseif strcmp(opMode, 'Complex Signal')
        pos = get(handles.InPhaseAxes, 'Position');
        pos(3) = sz.AxesWidth * 0.95;
        set(handles.InPhaseAxes, 'Position', pos);
        pos = get(handles.QuadratureAxes, 'Position');
        pos(3) = sz.AxesWidth * 0.95;
        set(handles.QuadratureAxes, 'Position', pos);
    end
else
    if strcmp(opMode, 'Real Signal')
        pos = get(handles.InPhaseAxes, 'Position');
        pos(3) = sz.AxesWidth;
        set(handles.InPhaseAxes, 'Position', pos);
    elseif strcmp(opMode, 'Complex Signal')
        pos = get(handles.InPhaseAxes, 'Position');
        pos(3) = sz.AxesWidth;
        set(handles.InPhaseAxes, 'Position', pos);
        pos = get(handles.QuadratureAxes, 'Position');
        pos(3) = sz.AxesWidth;
        set(handles.QuadratureAxes, 'Position', pos);
    end
end

%-------------------------------------------------------------------------------
% [EOF]
