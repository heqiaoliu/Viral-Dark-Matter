function updateschedule(h);
%UPDATESCHEDULE  Update axes schedule for multipath figure object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:54 $

axObjs = h.AxesObjects;
numAxes = h.NumAxes;

axesIndices = [];
timeStamps = [];
snapshotIndices = [];
for idx = 1:numAxes
    ax = axObjs{idx};
    if ax.Active
        tStamp = ax.SnapshotTimeStampVector;
        numt = length(tStamp);
        axesIndices = [axesIndices idx(ones(1, numt))];
        timeStamps = [timeStamps tStamp];
        snapshotIndices = [snapshotIndices 1:numt];
    end
end
[h.TimeStampSchedule sortIdx] = sort(timeStamps);

h.AxesIdxSchedule = axesIndices(sortIdx);
h.SnapshotIdxSchedule = snapshotIndices(sortIdx);

h.ScheduleUpdated = true;
