function dataInTs = storeDataValuesInTimeseries(data, inportInfo, fundamentalSampleTime)

%   Copyright 2009 The MathWorks, Inc.
    
    % disable the unwanted warnings
    warningstatus = warning('query','timeseries:init:istimefirst');     
    warning('off','timeseries:init:istimefirst');
    
    timeExpanded = Sldv.DataUtils.expandTimeForTimeseries(data.timeValues, fundamentalSampleTime);
                    
    dataInTs = Sldv.DataUtils.constructDataValuesForTsInport( ...
        1, ...
        inportInfo, ...
        timeExpanded, ...
        data.timeValues, ...
        data.dataValues);
    
    % enable them back
    warning(warningstatus.state,'timeseries:init:istimefirst');
end
