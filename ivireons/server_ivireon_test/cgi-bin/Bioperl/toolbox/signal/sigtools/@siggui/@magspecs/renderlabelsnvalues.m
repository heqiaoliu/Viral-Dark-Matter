function pos = renderlabelsnvalues(hObj, pos)
%RENDERLABELSNVALUES

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:24:22 $

sz = gui_sizes(hObj);

% Get the handle to the LabelsAndValues class
% Render the LabelsAndValues class
render(getcomponent(hObj, 'siggui.labelsandvalues'), hObj.FigureHandle, ...
    [pos(1)+sz.hfus pos(2) pos(3)-3*sz.hfus pos(4)-sz.uh-sz.vfus-3*sz.uuvs]);

% [EOF]
