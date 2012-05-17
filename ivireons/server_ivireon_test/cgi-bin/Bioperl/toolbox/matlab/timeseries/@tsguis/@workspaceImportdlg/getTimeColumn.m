function [time, timeFormat]=getTimeColumn(h,SelectedRows)
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
% Copyright 1986-2006 The MathWorks, Inc.

if isempty(SelectedRows)
    time=[];
    timeFormat=[];
    return
end
% check platform
if ~isempty(h.IOData.SelectedVariableInfo)
    % get the available column headings into a cell array
    tmpColStr=get(h.Handles.COMBtimeIndex,'String');
    tmpColValue=str2double(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
    % get value from each cell selected
    data=h.checkTimeFormat(h.IOData.SelectedVariableInfo.varname,'column',tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
    % check time format
    if h.IOData.formatcell.columnIsAbsTime>=0
        % absolute format
        % get discontinuous blocks
        blocks=h.GetBlocks(SelectedRows);
        time={};
        for i=1:size(blocks,1)
            % multiple blocks
            % get the time in the block
            tmptime=data([blocks(i,1):blocks(i,2)],tmpColValue);
            % remove cell wrap
            if iscell(tmptime)
                try
                    tmptime=cell2mat(tmptime);
                catch
%                     errordlg('Each time point in the time vector stored in a cell array must have the same size and same format.','Time Series Tools');
%                     time=[];
%                     timeFormat=[];
%                     return
                end
            end
            % convert it into matlab time string
            try
                tmptime=datestr(tmptime,h.IOData.formatcell.columnIsAbsTime);
                tmptime=mat2cell(tmptime,ones(1,size(tmptime,1)),size(tmptime,2));
            catch
                % not an absolute date/time format
                time=[];
                timeFormat=[];
                return
            end
            % set matlab time format
            if ~isempty(tmptime)
                timeFormat=h.IOData.formatcell.columnIsAbsTime;
            else
                time=[];
                timeFormat=[];
                return
            end
            time=[time;tmptime];
        end
    elseif h.IOData.formatcell.columnIsAbsTime==-1
        % relative time format
        % get discontinuous blocks
        blocks=h.GetBlocks(SelectedRows);
        time=[];
        for i=1:size(blocks,1)
            % multiple blocks
            % get the time in the block
            tmptime=data([blocks(i,1):blocks(i,2)],tmpColValue);
            % remove cell wrap
            if iscell(tmptime)
                tmptime=cell2mat(tmptime);
                try
                    tmptime=cell2mat(tmptime);
                catch
                    errordlg('Invalid times selected. Correct them or re-select the time vector.',...
                       'Time Series Tools','modal');
                    time=[];
                    timeFormat=[];
                    return
                end
            end
            % check if it a valid relative time format (a number)
            if sum(~isnumeric(tmptime))>0 || sum(isnan(tmptime))>0
                time=[];
                timeFormat=[];
                return
            end
            % set matlab time format
            if ~isempty(tmptime)
                timeFormat=-1;
            else
                time=[];
                timeFormat=[];
                return
            end
            time=[time;tmptime];
        end
    else
        time=[];
        timeFormat=[];
        return
    end
end
