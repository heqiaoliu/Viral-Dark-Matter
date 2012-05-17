function time=getTimeVectorRange(h,starttime,endtime)
% GETTIMEVECTORRANGE returns the valid time vector between starttime and
% endtime

% The return value will be the indices of the valid time values in the
% range or empty if not found. 'starttime' and 'endtime' are strings.

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2010 The MathWorks, Inc.

% check platform
if ~isempty(h.Handles.ActiveX)
    % using ActiveX
    % get active workbook
    eActiveWorkbook=h.Handles.ActiveX.ActiveWorkbook;
    % the time vector is selected from the same sheet
    eActiveSheet=eActiveWorkbook.ActiveSheet;
    SheetSize = h.IOData.currentSheetSize(eActiveSheet.Index,:);
    
    % check time vector is a column or a row
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is a column
        % get the available column headings into a cell array
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        ColStr=tmpColStr{get(h.Handles.COMBtimeIndex,'Value')};
        % check time format
        if h.IOData.formatcell.columnIsAbsTime>=0
            % absolute format
            time=[];
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
            catch %#ok<CTCH>
                return;
            end
            if first>last
                tmp=first;
                first=last;
                last=tmp;
            end
            % get the whole column for search
            tmpRange = eActiveSheet.Range([ColStr num2str(1) ':' ColStr num2str(SheetSize(1))]);
            timeValue=tmpRange.Value;
            % search the column for the first time point within the range
            h.Handles.bar=waitbar(10/100,'Searching matched time points now.  It may take a while.  Please Wait...');
            for i=1:SheetSize(1)
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(h.IOData.formatcell.columnFormat,{tmpTime},ColStr,'col');
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.columnIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(50/100,h.Handle.bar);
            end
            % search the column for the last time point within the range
            for i=SheetSize(1):-1:1
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(h.IOData.formatcell.columnFormat,{tmpTime},ColStr,'col');
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.columnIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(100/100,h.Handle.bar);
            end
            time=sort(time);
            delete(h.Handle.bar);
        else
            % relative time (double values)
            time=[];
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
            tmpRange = eActiveSheet.Range([ColStr num2str(1) ':' ColStr num2str(SheetSize(1))]);
            timeValue=tmpRange.Value;
            % search the column for the first time point within the range
            h.Handles.bar=waitbar(10/100,'Searching matched time points now.  It may take a while.  Please Wait...');
            for i=1:SheetSize(1)
                tmpTime=timeValue{i};
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(50/100,h.Handle.bar);
            end
            % search the column for the last time point within the range
            for i=SheetSize(1):-1:1
                tmpTime=timeValue{i};
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(100/100,h.Handle.bar);
            end
            time=sort(time);
            delete(h.Handle.bar);
        end
    else
        % the time vector is stored in a row
        % get the available row headings into a cell array
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        RowStr=tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')};
        % check time format
        if h.IOData.formatcell.rowIsAbsTime>=0
            % absolute format
            time=[];
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
            catch %#ok<CTCH>
                return;
            end
            if first>last
                tmp=first;
                first=last;
                last=tmp;
            end
            % get the whole row for search
            tmpRange = eActiveSheet.Range([h.findcolumnletter(1) num2str(RowStr) ':' h.findcolumnletter(SheetSize(2)) num2str(RowStr)]);
            timeValue=tmpRange.Value;
            % search the row for the first time point within the range
            h.Handles.bar=waitbar(10/100,'Searching matched time points now.  It may take a while.  Please Wait...');
            for i=1:SheetSize(2)
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(h.IOData.formatcell.rowFormat,{tmpTime},num2str(RowStr),'row');
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.rowIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(50/100,h.Handle.bar);
            end
            % search the column for the last time point within the range
            for i=SheetSize(2):-1:1
                tmpTime=timeValue{i};
                [formatflag,tmpValue]=h.IsTimeFormat(h.IOData.formatcell.rowFormat,{tmpTime},num2str(RowStr),'row');
                if ~((isnumeric(tmpTime) && isnan(tmpTime)) || formatflag<0 || isnan(formatflag)) && formatflag==h.IOData.formatcell.rowIsAbsTime
                    % a time/date format and compare to the range
                    if tmpValue>=first && tmpValue<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(100/100,h.Handle.bar);
            end
            time=sort(time);
            delete(h.Handle.bar);
        else
            % relative time (double values)
            time=[];
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
            tmpRange = eActiveSheet.Range([h.findcolumnletter(1) num2str(RowStr) ':' h.findcolumnletter(SheetSize(2)) num2str(RowStr)]);
            timeValue=tmpRange.Value;
            % search the column for the first time point within the range
            h.Handles.bar=waitbar(10/100,'Searching matched time points now.  It may take a while.  Please Wait...');
            for i=1:SheetSize(2)
                tmpTime=timeValue{i};
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(1)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(50/100,h.Handle.bar);
            end
            % search the column for the last time point within the range
            for i=SheetSize(2):-1:1
                tmpTime=timeValue{i};
                if isnumeric(tmpTime) && ~isnan(tmpTime)
                    if tmpTime>=first && tmpTime<=last
                        time(2)=i;
                        break;
                    end
                end
            end
            if ishandle(h.Handles.bar)
                waitbar(100/100,h.Handle.bar);
            end
            time=sort(time);
            delete(h.Handle.bar);
        end
    end
else
    % using uitable
    % get active sheet
    tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));

    % check time vector is a column or a row
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is a column
        % get the available column headings into a cell array
        time=[];
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
        timeValue = tmpSheet(1:size(tmpSheet,1),get(h.Handles.COMBtimeIndex,'Value'));
        % search the column for the first time point within the range
        for i=1:size(tmpSheet,1)
            tmpTime=timeValue{i};
            if isnumeric(tmpTime) && ~isnan(tmpTime)
                if tmpTime>=first && tmpTime<=last
                    time(1)=i;
                    break;
                end
            end
        end
        % search the column for the last time point within the range
        for i=size(tmpSheet,1):-1:1
            tmpTime=timeValue{i};
            if isnumeric(tmpTime) && ~isnan(tmpTime)
                if tmpTime>=first && tmpTime<=last
                    time(2)=i;
                    break;
                end
            end
        end
        time=sort(time);
    else
        % the time vector is stored in a row
        % get the available row headings into a cell array
        time=[];
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
        timeValue = tmpSheet(get(h.Handles.COMBtimeIndex,'Value'),1:size(tmpSheet,2));
        % search the column for the first time point within the range
        for i=1:size(tmpSheet,2)
            tmpTime=timeValue{i};
            if isnumeric(tmpTime) && ~isnan(tmpTime)
                if tmpTime>=first && tmpTime<=last
                    time(1)=i;
                    break;
                end
            end
        end
        % search the column for the last time point within the range
        for i=size(tmpSheet,2):-1:1
            tmpTime=timeValue{i};
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