function storeoutput(h, y)

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/14 15:01:01 $

% One Statistics object for all channel(s)
if length(h.CutoffFrequency) == 1
    if h.Statistics.Enable
        update(h.Statistics, y.');
    end
% One Statistics object per channel    
else
    for i = 1:length(h.CutoffFrequency)
        if h.Statistics(i).Enable   % Enable should be the same for all channels
            update(h.Statistics(i), y(i,:).');
        end
    end
end