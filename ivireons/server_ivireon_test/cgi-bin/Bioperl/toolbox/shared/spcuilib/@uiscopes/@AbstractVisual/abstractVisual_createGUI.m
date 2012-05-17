function plan = abstractVisual_createGUI(this) %#ok
%ABSTRACTVISUAL_CREATEGUI Add the dimensions status item.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/08/14 04:07:41 $

hDims = uimgr.uistatus(sprintf('%s Dims', class(this)), @status_opt_dims);
hDims.Placement = -2;

plan = {hDims, 'Base/StatusBar/StdOpts'};

function y = status_opt_dims(h)

if ispc
    w = 80;
else
    w = 104;
end

y = spcwidgets.Status(h.GraphicalParent, ...
    'Width', w, 'Tag', [h.Name 'Status']);

% [EOF]
