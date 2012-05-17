function flag=IgnoreFirstColumnRow(h)
% CHECKTIMEFORMAT implement first column/row time vector smart detection
% return java indexed position of first valid time (either absolute or
% relative).

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

flag=0;

% data is organized by column
if get(h.Handles.COMBdataSample,'Value')==1
    % get active sheet
    tmpSheet = h.IOData.rawdata;
    % get column index
    tmpColStr = get(h.Handles.COMBtimeIndex,'String');
    tmpColNumber = h.findcolumnnumber(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
    % check
    tmpEndRow=min(size(tmpSheet,1),h.IOData.checkLimit);
    for i=1:tmpEndRow
        TimePoint = cell2mat(tmpSheet(i,tmpColNumber));
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
    if flag>=size(tmpSheet,1)
        flag = [];
    end
% data is organized by row
else
    % get active sheet
    tmpSheet = h.IOData.rawdata;
    % get row index
    tmpRowStr = get(h.Handles.COMBtimeIndex,'String');
    tmpRowNumber = str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
    % check
    tmpEndColumn = min(size(tmpSheet,2),h.IOData.checkLimit);
    for i=1:tmpEndColumn
        TimePoint = tmpSheet(tmpRowNumber,i);
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
    if flag>=size(tmpSheet,2)
        flag = [];
    end
end


    