function scrollBarSliderAction(dp)
% User interaction with scroll bar slider

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:17 $

val = get(dp.hScrollBar,'Value'); % normalized in range [0,1]
frac = 1-val; % reorient
setPanelViewFraction(dp,frac);
