function setsnapshotprops(h);
%SETSNAPSHOTPROPS  Set snapshot properties for multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:11 $

% Get buffer length and number of new samples.
bufferLength = h.BufferLength;
numNewSamples = h.NumNewSamples;

% Determine number of snapshots.
maxSnaps = h.MaxNumSnapshots;
if (maxSnaps==1)
    nSnaps = 1;
else
    nSnaps = ceil(maxSnaps * (numNewSamples/bufferLength));    
end

% Snapshot-related properties.
h.NumSnapshots = nSnaps;
h.SnapshotTimeStampVector = (1:nSnaps)/maxSnaps;
h.SampleIdxVector = round(linspace(numNewSamples/nSnaps, ...
    numNewSamples, nSnaps));
h.SampleIdxEndOld = bufferLength - numNewSamples;
