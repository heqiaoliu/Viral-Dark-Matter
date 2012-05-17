function [hParentForDialogBorder,width,height] = getDialogPanelAndSize(dp)
% Return uipanel handle that serves as graphical parent for DialogBorder
% child widgets.
%
% Optionally return width and height of dialog panel, in pixels.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:49 $

hParentForDialogBorder = dp.hDialogPanel;
if nargout>1
    ppos = get(hParentForDialogBorder,'pos'); % pixels
    width = ppos(3);
    height = ppos(4);
end
