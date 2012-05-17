function [time, timeValue]=getTimeVectorRange(h,starttime,endtime)
% GETTIMEVECTORRANGE returns the valid time vector between starttime and
% endtime

% The return value will be the indices of the valid time values in the
% range or empty if not found. 'starttime' and 'endtime' are strings.

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2006 The MathWorks, Inc.

time=[];
timeValue={};
% check platform
if ~isempty(h.IOData.SelectedVariableInfo)
    data=evalin('base',h.IOData.SelectedVariableInfo.varname);
    % check time vector is a column or a row
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is a column
        % get the available column headings into a cell array
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        ColStrValue=str2double(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        % check time format
        if h.IOData.formatcell.columnIsAbsTime>=0
            % absolute format
            % get their numeric values and sort them
            try 
                if h.IOData.formatcell.columnIsAbsTime==13 || h.IOData.formatcell.columnIsAbsTime==14 || ...
                   h.IOData.formatcell.columnIsAbsTime==15 || h.IOData.formatcell.columnIsAbsTime==16
                    first=datevec(starttime);
                    last=datevec(endtime);
                    first=datenum([0 0 0 first(4:6)]);
                    last=datenum([0 0 0 last(4:6)]);
                else
                    first=datenum(starttime);
                    last=datenum(endtime);
                end
            catch
                return;
            end
            if first>last
                tmp=first;
                first=last;
                last=tmp;
            end
            % get the whole column for search
            timeValue = data(1:h.IOData.SelectedVariableInfo.objsize(1),ColStrValue);
            % search the column for the first time point within the range
            for i=1:h.IOData.SelectedVariableInfo.objsize(2)
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(tmpTime);
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.columnIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            % search the column for the last time point within the range
            for i=h.IOData.SelectedVariableInfo.objsize(1):-1:1
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(tmpTime);
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.columnIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            time=sort(time);
        else
            % relative time (double values)
            % get their numeric values and sort them
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
            % get the whole column for search
            timeValue=data(1:h.IOData.SelectedVariableInfo.objsize(1),ColStrValue);
            tmpIsCell=iscell(timeValue);
            % search the column for the first time point within the range
            for i=1:h.IOData.SelectedVariableInfo.objsize(1)
                if tmpIsCell
                    tmpTime=timeValue{i};
                else
                    tmpTime=timeValue(i);
                end
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            % search the column for the last time point within the range
            for i=h.IOData.SelectedVariableInfo.objsize(1):-1:1
                if tmpIsCell
                    tmpTime=timeValue{i};
                else
                    tmpTime=timeValue(i);
                end
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            time=sort(time);
        end
    else
        % the time vector is stored in a row
        % get the available row headings into a cell array
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        RowStrValue=str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        % check time format
        if h.IOData.formatcell.rowIsAbsTime>=0
            % absolute format
            % get their numeric values and sort them
            try 
                if h.IOData.formatcell.rowIsAbsTime==13 || h.IOData.formatcell.rowIsAbsTime==14 || ...
                   h.IOData.formatcell.rowIsAbsTime==15 || h.IOData.formatcell.rowIsAbsTime==16
                    first=datevec(starttime);
                    last=datevec(endtime);
                    first=datenum([0 0 0 first(4:6)]);
                    last=datenum([0 0 0 last(4:6)]);
                else
                    first=datenum(starttime);
                    last=datenum(endtime);
                end
            catch
                return;
            end
            if first>last
                tmp=first;
                first=last;
                last=tmp;
            end
            % get the whole row for search
            timeValue=data(RowStrValue,1:h.IOData.SelectedVariableInfo.objsize(2));
            % search the row for the first time point within the range
            for i=1:h.IOData.SelectedVariableInfo.objsize(2)
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(tmpTime);
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.rowIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            % search the column for the last time point within the range
            for i=h.IOData.SelectedVariableInfo.objsize(2):-1:1
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(tmpTime);
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.rowIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            time=sort(time);
        else
            % relative time (double values)
            % get their numeric values and sort them
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
            % get the whole row for search
            timeValue=data(RowStrValue,1:h.IOData.SelectedVariableInfo.objsize(2));
            tmpIsCell=iscell(timeValue);
            % search the column for the first time point within the range
            for i=1:h.IOData.SelectedVariableInfo.objsize(2)
                if tmpIsCell
                    tmpTime=timeValue{i};
                else
                    tmpTime=timeValue(i);
                end
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            % search the column for the last time point within the range
            for i=h.IOData.SelectedVariableInfo.objsize(2):-1:1
                if tmpIsCell
                    tmpTime=timeValue{i};
                else
                    tmpTime=timeValue(i);
                end
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            time=sort(time);
        end
    end
end
timeValue=timeValue(time);