function [time, timeFormat, customFormat]=getTimeColumn(h,SelectedRows)
% GETTIMECOLUMN returns the time vector based on the dataset selected by
% the user in the import dialog.  

% If the time vector is in absolute time format (e.g. hh:mm:ss), the return
% value will be a cell column with each cell as a time string.  If the time
% vector is in relative time format with unit (e.g. 1 sec), the return
% value will be a double column.  If the selected values are not valid, the
% return value is empty. timeformat stores the Standard MATLAB format
% number (from 0~31 if any). SelectedRows can be discontinuous

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

customFormat='';
if isempty(SelectedRows)
    time=[];
    timeFormat=[];
    return
end

tmpSheet = h.IOData.rawdata;

% get the available column headings into a cell array
tmpColStr = get(h.Handles.COMBtimeIndex,'String');
% get time points in cell array
time = tmpSheet(SelectedRows,h.findcolumnnumber(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')}));
% try to convert cell into matlab variable
try
    if all(cellfun('isclass',time,'char'))
        time = char(time); 
    else
        time = cell2mat(time);
    end
catch
    errordlg('Invalid times selected. Correct them or re-select the time vector.',...
        'Time Series Tools','modal');
    time=[];
    timeFormat=[];
    return
end
if ischar(time) && ~isempty(time)
    try
        time = datestr(time);
        time = mat2cell(time,ones(1,size(time,1)),size(time,2));
        if ~isempty(strfind(time{1},':'))
            timeFormat = 0;
        else
            timeFormat = 1;
        end
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


