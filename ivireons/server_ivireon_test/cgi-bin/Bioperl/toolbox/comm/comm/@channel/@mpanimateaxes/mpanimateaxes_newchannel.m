function mpanimateaxes_newchannel(h, chan);
%MPANIMATEAXES_NEWCHANNEL  Store new channel data in multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:04 $

% Extract data from channel object.
PGH = chan.PathGainHistory;
h.FirstPlot = h.FirstPlot || (size(PGH.Buffer, 1) ~= h.BufferLength);
h.BufferLength = size(PGH.Buffer, 1);
h.NumNewSamples = PGH.NumNewSamples;

% Set snapshot-related properties.
setsnapshotprops(h);

