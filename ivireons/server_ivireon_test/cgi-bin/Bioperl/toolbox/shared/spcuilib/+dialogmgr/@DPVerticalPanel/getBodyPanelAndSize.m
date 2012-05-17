function [hBodyPanel,width,height] = getBodyPanelAndSize(dp)
% Return BodyPanel uipanel handle.
%
% Optionally return width and height of body panel, in pixels.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:47 $

hBodyPanel = dp.hBodyPanel;
if nargout>1
    pos = get(hBodyPanel,'pos');
    width = pos(3);
    height = pos(4);
end
