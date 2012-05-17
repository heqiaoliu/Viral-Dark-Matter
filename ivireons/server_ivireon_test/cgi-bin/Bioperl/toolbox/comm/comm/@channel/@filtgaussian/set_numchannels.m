function N = set_numchannels(h, N)

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/14 15:00:59 $

check_object_locked(h, 'number of channels');

h.PrivateData.NumChannels = N;


if length(h.Statistics)==1
    % One Statistics object for all channels, containing N channels 
    h.Statistics.NumChannels = N;
else
    % One Statistics object for per channel, each one containing one channel
end    
