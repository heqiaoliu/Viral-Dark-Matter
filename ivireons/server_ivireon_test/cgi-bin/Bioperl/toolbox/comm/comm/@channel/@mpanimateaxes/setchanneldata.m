function setchanneldata(h, x);
%SETCHANNELDATA  Store channel data in multipath animation axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:09 $

% Set old channel data.
if (h.FirstPlot)
    uNaN = NaN;
    h.OldChannelData = uNaN(ones(size(x)));
else
    h.OldChannelData = h.NewChannelData;
end

% Set new channel data.
h.NewChannelData = x;
