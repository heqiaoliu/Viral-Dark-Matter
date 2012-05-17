function storeOutput(h, y)

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:03 $

% One Statistics object for all channel(s)
if length(h.PrivateData.CutoffFrequency) == 1
    if h.Statistics.Enable
        NC = h.PrivateData.NumChannels;
        NL = h.PrivateData.NumLinks;
        ys = zeros(NC,size(y,2));
        % Store only statistics of link #1
        for i = 1:NC
            ys(i,:) = y(1+(i-1)*NL,:);
        end    
        update(h.Statistics, ys.');
    end
% One Statistics object per channel    
else
    NL = h.PrivateData.NumLinks;
    for i = 1:length(h.PrivateData.CutoffFrequency)
        if h.Statistics(i).Enable   % Enable should be the same for all channels
            % Store only statistics of link #1
            update(h.Statistics(i), y(1+(i-1)*NL,:).');
        end
    end
end