function setslider(h, sliderObj);
%SETSLIDER  Slider callback for multipath figure object.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/02/14 16:07:12 $

% If an animation mode is selected, put in pause mode.
uiHandles = h.UIHandles;
pb = h.UIHandles.PauseButton;
if (get(pb, 'Value')==0)
    set(pb, 'Value', 1);
    set(pb, 'String', 'Resume');
end

% Update snapshot according to slider setting.
h.refreshsnapshot;
