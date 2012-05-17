function [vrfig, canvas] = vrgcbf
%VRGCBF Get the current callback VRFIGURE object.
%   F = VRGCBF returns a VRFIGURE object representing the VR figure
%   that contains the callback being currently executed.
%
%   When no VR figure callbacks are executing, VRGCBF returns
%   an empty array of VRFIGURE objects.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/03/01 05:30:17 $ $Author: batserve $

[handle, nativeCanvas] = vrsfunc('GetCallbackFigure');
if handle == 0
  % it is vr5 mode callback
  if nativeCanvas ~= 0
    % it is  callback from C++
    list = getappdata(0, 'SL3D_vrcanvas_List');
    canvas = list(nativeCanvas); 
    fig = getappdata(canvas.mfigure, 'vrfigure');
    vrfig = vrfigure(fig);
  else
    % it is MATLAB callback
    fig = vr.figure.gcbf;
    vrfig = vrfigure(fig);
    if ~isempty(fig)
      canvas = fig.canvas;
    else
      canvas = [];
    end
  end
else
  % it is old vrfigure mode callback
  vrfig = vrfigure(handle);
  canvas = [];
end
