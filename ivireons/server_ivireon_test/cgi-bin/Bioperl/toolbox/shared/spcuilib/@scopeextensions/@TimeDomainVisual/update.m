function update(this, startTime, endTime)
%UPDATE   Call the update function

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/21 21:49:29 $

source = this.Application.DataSource;

trange  = this.TimeRange;
if nargin < 3
    
    % Get the end time from the source.
    endTime = getTimeOfDisplayData(source);
end

displayStartTime = trange*floor(endTime/trange);

% Make sure that we do not wrap when the next point will land right on the
% end time.
if this.LengthOfChannels == 1 && ...
        displayStartTime == endTime && ...
        displayStartTime ~= getOriginTime(source)
    displayStartTime = displayStartTime-trange;
end

if nargin < 2
    startTime = displayStartTime;
end

this.TimeOffset = displayStartTime;

% Format all the data.
allData = getData(source, startTime, endTime);

% Call the specific update fcn, frame vs samples.
this.UpdateFcn(this, allData);

% [EOF]
