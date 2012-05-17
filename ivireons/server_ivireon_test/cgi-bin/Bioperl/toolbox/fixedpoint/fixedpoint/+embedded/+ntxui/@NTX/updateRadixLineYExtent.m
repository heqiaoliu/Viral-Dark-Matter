function updateRadixLineYExtent(ntx)
% Update RadixLine y-extent.
%
% Check if overflow and underflow lines are both on the "same side"
% of the radix line.  If so, lengthen radix line height to top of axis
% since the wordspan line no longer intersects it.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:10 $

if (ntx.LastUnder >= ntx.RadixPt) || (ntx.LastOver  <= ntx.RadixPt)
    ylim = get(ntx.hHistAxis,'ylim'); % height in data units
    yd = [0 ylim(2)];          % Take it up to top of axis
else
    % set radix line height to touch wordspan horiz line
    yd = [0 ntx.yWordSpan];
end
set(ntx.hlRadixLine,'ydata',yd);
