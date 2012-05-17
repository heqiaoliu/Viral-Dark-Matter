function [f, c] = vrgcf
%VRGCF Get the current VRFIGURE object.
%   F = VRGCF returns a VRFIGURE object representing the current VR figure.
%   The current figure is the figure that currently has keyboard and mouse
%   focus.
%
%   When no VR figure exists, VRGCF returns an empty array of VRFIGURE
%   objects.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/05/07 18:28:58 $ $Author: batserve $

[handle, canvas] = vrsfunc('GetCurrentFigure');

% a canvas is current - map it to a vrfigure if possible
if canvas ~= 0
  allfigs = getappdata(0, 'SL3D_vrfigure_List');
  if ~isempty(allfigs) && allfigs.isKey(canvas)
    f = vrfigure(allfigs(canvas));
  else
    f = vrfigure([]);
  end

  % optionally return vr.canvas object
  % this is undocumented and likely to change
  if nargout>1
    allcanvas = getappdata(0, 'SL3D_vrcanvas_List');
    if allcanvas.isKey(canvas)
      c = allcanvas(canvas);
    else
      c = vr.canvas([]);
    end
  end
  
% an old vrfigure is current
else
  if handle ~= 0
    f = vrfigure(handle);
  else
    f = vrfigure([]);
  end
  c = vr.canvas([]);
end
