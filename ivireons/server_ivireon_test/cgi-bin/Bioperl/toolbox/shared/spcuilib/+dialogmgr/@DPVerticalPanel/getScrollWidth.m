function scroll = getScrollWidth(dp)
% Get width of scroll bar in pixels.
% If scroll bar should not be visible, scroll width is returned as zero.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:53 $

if dp.PanelVisible && (dp.ScrollFraction < 1)
    scroll = dp.ScrollWidth;
else
    scroll = 0;
end
