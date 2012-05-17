function [time, timeFormat, customFormat]=getTimeRow(h,SelectedColumns)
% GETTIMEROW returns the time vector based on the dataset selected by
% the user in the import dialog.  

% If the time vector is in absolute time format (e.g. hh:mm:ss), the return
% value will be a cell column with each cell as a time string.  If the time
% vector is in relative time format with unit (e.g. 1 sec), the return
% value will be a double column.  If the selected values are not valid, the
% return value is empty. timeformat stores the Standard MATLAB format
% number (from 0~31 if any). SelectedRows can be discontinuous


% Revised: 
% Copyright 2004-2009 The MathWorks, Inc.

customFormat='';
if isempty(SelectedColumns)
    time=[];
    timeFormat=[];
    return
end

if ~isempty(h.Handles.tsTable)
    % using uitable
    % get active sheet
    tmpSheet=h.IOData.rawdata;

    % get the available row numbers into a cell array
    tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
    % get time points in cell array
    time=tmpSheet(str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')}),SelectedColumns);
    % try to convert cell into matlab variable
    try
        time=cell2mat(time');
    catch
        errordlg('Invalid times selected. Correct them or re-select the time vector.',...
            'Time Series Tools','modal');
        time=[];
        timeFormat=[];
        return
    end
    if ischar(time) && ~isempty(time)
        try
            time=datestr(time);
            time=mat2cell(time,ones(1,size(time,1)),size(time,2));
            timeFormat=0;
            return
        catch
            % not an absolute date/time format
            time=[];
            timeFormat=[];
            return
        end
    else
        if isempty(time) || sum(~isnumeric(time))>0 || sum(isnan(time))>0
            time=[];
            timeFormat=[];
            return;
        end        
    end
    timeFormat=-1;
end
