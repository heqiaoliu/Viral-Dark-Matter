function flag=IgnoreFirstColumnRow(h)
% CHECKTIMEFORMAT implement first column/row time vector smart detection
% return true if the first n cells contain time (either absolute or
% relative).

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

flag=0;
if ~isempty(h.Handles.ActiveX)
    SheetSize = h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,:);
    if get(h.Handles.COMBdataSample,'Value')==1
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        tmpEndRow=min(h.IOData.checkLimit,SheetSize(1));
        tmpRange=[tmpColStr{get(h.Handles.COMBtimeIndex,'Value')} '1' ':' ...
            tmpColStr{get(h.Handles.COMBtimeIndex,'Value')} num2str(tmpEndRow)];
        tmpTime=h.Handles.ActiveX.ActiveSheet.Range(tmpRange).Value;
        if h.IOData.formatcell.columnIsAbsTime>=0
            % suppose to be an absolute date/time value
            for i=1:tmpEndRow
                if iscell(tmpTime(i))
                    TimePoint=tmpTime{i};
                else
                    TimePoint=tmpTime(i);
                end
                try
                    if ischar(TimePoint)
                        dummy=datestr(datenum(TimePoint,h.IOData.formatcell.columnFormat{:}),h.IOData.formatcell.columnFormat{:});
                    else
                        dummy=datestr(TimePoint,h.IOData.formatcell.columnFormat{:});
                    end
                    break;
                catch
                    % not an absolute date/time format, move to the second row
                    flag=flag+1;
                end
            end
        elseif h.IOData.formatcell.columnIsAbsTime==-1
            % suppose to be a relative time value
            for i=1:tmpEndRow
                if iscell(tmpTime(i))
                    TimePoint=tmpTime{i};
                else
                    TimePoint=tmpTime(i);
                end
                if ~isnumeric(TimePoint) || isnan(TimePoint)
                    flag=flag+1;
                else
                    break;
                end
            end
        else
            flag=tmpEndRow;
        end
    else
        % time vector is stored as a row
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        tmpEndColumn=min(h.IOData.checkLimit,SheetSize(2));
        tmpRange=['A' tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')} ...
            ':' h.findcolumnletter(tmpEndColumn) tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')}];
        tmpTime=h.Handles.ActiveX.ActiveSheet.Range(tmpRange).Value;
        if h.IOData.formatcell.rowIsAbsTime>=0
            % suppose to be an absolute date/time value
            for i=1:tmpEndColumn
                if iscell(tmpTime(i))
                    TimePoint=tmpTime{i};
                else
                    TimePoint=tmpTime(i);
                end
                try
                    if ischar(TimePoint)
                        dummy=datestr(datenum(TimePoint,h.IOData.formatcell.rowFormat{:}),h.IOData.formatcell.rowFormat{:});
                    else
                        dummy=datestr(TimePoint,h.IOData.formatcell.rowFormat{:});
                    end
                    break;
                catch
                    % not an absolute date/time format, move to the second row
                    flag=flag+1;
                end
            end
        elseif h.IOData.formatcell.rowIsAbsTime==-1
            % suppose to be a relative time value
            for i=1:tmpEndColumn
                if iscell(tmpTime(i))
                    TimePoint=tmpTime{i};
                else
                    TimePoint=tmpTime(i);
                end
                if ~isnumeric(TimePoint) || isnan(TimePoint)
                    flag=flag+1;
                else
                    break;
                end
            end
        else
            flag=tmpEndColumn;
        end
    end
end

if ~isempty(h.Handles.tsTable)
    % data is organized by column
    if get(h.Handles.COMBdataSample,'Value')==1
        % get active sheet
        tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));
        % get column index
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        tmpColNumber=h.findcolumnnumber(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        % check
        tmpEndRow=min(size(tmpSheet,1),h.IOData.checkLimit);
        for i=1:tmpEndRow
            TimePoint=cell2mat(tmpSheet(i,tmpColNumber));
            if ischar(TimePoint)
                if isempty(TimePoint)
                    flag=flag+1;
                else
                    try
                        dummy=datestr(TimePoint);
                        break;
                    catch
                        % not an absolute date/time format, move to the second row
                        flag=flag+1;
                    end
                end
            else
                break;
            end
        end
    % data is organized by row
    else
        % get active sheet
        tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));
        % get row index
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        tmpRowNumber=str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        % check
        tmpEndColumn=min(size(tmpSheet,2),h.IOData.checkLimit);
        for i=1:tmpEndColumn
            TimePoint=cell2mat(tmpSheet(tmpRowNumber,i));
            if ischar(TimePoint)
                if isempty(TimePoint)
                    flag=flag+1;
                else
                    try
                        dummy=datestr(TimePoint);
                        break;
                    catch
                        % not an absolute date/time format, move to the second row
                        flag=flag+1;
                    end
                end
            else
                break;
            end
        end
    end
end
    