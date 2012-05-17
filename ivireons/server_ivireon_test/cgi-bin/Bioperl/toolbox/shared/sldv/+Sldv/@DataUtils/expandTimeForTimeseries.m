function timeExpanded = expandTimeForTimeseries(time, fundamentalSampleTime, fundamentalSampleTimeExpand)

%   Copyright 2008-2009 The MathWorks, Inc.

    if nargin<3
        fundamentalSampleTimeExpand = fundamentalSampleTime;
    end
    numberSteps = floor((time(end)-time(1))/fundamentalSampleTime) + 1;
    timeExpanded = (0:(numberSteps-1))*fundamentalSampleTimeExpand;
end
