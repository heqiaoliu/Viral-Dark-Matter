function time=getTimeVectorRange(h,starttime,endtime)
% GETTIMEVECTORRANGE returns the valid time vector between starttime and
% endtime

% The return value will be the indices of the valid time values in the
% range or empty if not found. 'starttime' and 'endtime' are strings.

% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.


% check time vector is a column or a row
if get(h.Handles.COMBdataSample,'Value')==1
    % Time vector is a column
    % Get the available column headings into a cell array
    time = [];
    % Get their numeric values and sort them
    first = str2double(starttime);
    last = str2double(endtime);
    if isnan(first) || isnan(last)
        return
    end
    if first>last
        tmp = first;
        first = last;
        last = tmp;
    end
    % Get the whole column for search
    timeValue = h.IOData.rawdata(:,get(h.Handles.COMBtimeIndex,'Value'));
    % Search the column for the first time point within the range
    for i=1:size(h.IOData.rawdata,1)
        tmpTime = timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(1) = i;
                break;
            end
        end
    end
    % Search the column for the last time point within the range
    for i=size(h.IOData.rawdata,1):-1:1
        tmpTime = timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(2) = i;
                break;
            end
        end
    end
    time = sort(time);
else
    % The time vector is stored in a row
    % Get the available row headings into a cell array
    time=[];
    % Get their numeric values and sort them
    first=str2double(starttime);
    last=str2double(endtime);
    if isnan(first) || isnan(last)
        return
    end
    if first>last
        tmp=first;
        first=last;
        last=tmp;
    end
    % Get the whole row for search
    timeValue = h.IOData.rawdata(get(h.Handles.COMBtimeIndex,'Value'),:);
    % Search the column for the first time point within the range
    for i=1:size(h.IOData.rawdata,2)
        tmpTime = timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(1) = i;
                break;
            end
        end
    end
    % Search the column for the last time point within the range
    for i=size(h.IOData.rawdata,2):-1:1
        tmpTime = timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(2)=i;
                break;
            end
        end
    end
    time = sort(time);
end