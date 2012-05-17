function data=checkTimeFormat(h,name,colrow,indexStr)
% CHECKTIMEFORMAT checks the time format of the given row and/or column and
% update the information stored in 'h.IOData.formatcell' struct

% stored information
%   name: string, vaeriable name
%   columnIndex: integer, columnindex
%   rowIndex: integer, rowindex
%   columnIsAbsTime: integer, a time format 
%   rowIsAbsTime: integer, a time format 
%   
%   time format:
%   -1      double values, which could be relative time points
%   >=0     absolute date/time format supported by Matlab
%   NaN     not a time format (unrecognizable), e.g. a string
%
% inputs:   name: a string of the variable
%           colrow: a string of 'row', 'column', 'both'
%           index: a string of '1', '2', ... 

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.

% get data from workspace
data=evalin('base',name);
if strcmp(colrow,'column')
    % check a column
    % get column index
    try
        index=str2double(indexStr);
    catch
        return
    end
    % check and update
    localCheckColumn(h,data,name,index);
elseif strcmp(colrow,'row')
    % check a row
    try
        % get row index
        index=str2double(indexStr);
    catch
        return
    end
    % check and update
    localCheckRow(h,data,name,index);
elseif strcmp(colrow,'both')
    % only called once at the initialization stage
    % get index
    try
        index=str2double(indexStr);
    catch
        return
    end
    % try column
    localCheckColumn(h,data,name,index);
    % try row
    localCheckRow(h,data,name,index);
end
          

function localCheckColumn(h,data,name,index)
% check time format for a column and store information into formatcell

% initialize flag storage
h.IOData.formatcell.columnIsAbsTime=NaN;
% check the first element in the column
if iscell(data)
    % could have absolute date/time time vector
    for i=min(size(data,1),h.IOData.checkLimit):-1:1
        % check a few rows
        tmpFlag=h.IsTimeFormat(data{i,index});
        if tmpFlag<0
            % relative time
            h.IOData.formatcell.columnIsAbsTime=-1;
            break;
        else
            if ~isnan(tmpFlag)
                % absolute time
                h.IOData.formatcell.columnIsAbsTime=tmpFlag;
                break;
            end
        end
    end
else
    if ischar(data)
        tmpFlag=h.IsTimeFormat(data);
        if ~isnan(tmpFlag)
            h.IOData.formatcell.columnIsAbsTime=tmpFlag;
        end
    end
    if isnumeric(data)
        h.IOData.formatcell.columnIsAbsTime=-1;
    end
end
h.IOData.formatcell.columnIndex=index;
h.IOData.formatcell.rowIndex=0;
h.IOData.formatcell.name=name;


function localCheckRow(h,data,name,index)
% check time format for a row and store information into formatcell

% initialize flag storage
h.IOData.formatcell.rowIsAbsTime=NaN;
% check the first element in the row
if iscell(data)
    % could have absolute date/time time vector
    for i=min(size(data,2),h.IOData.checkLimit):-1:1
        % check a few rows
        tmpFlag=h.IsTimeFormat(data{index,i});
        if tmpFlag<0
            % relative time
            h.IOData.formatcell.rowIsAbsTime=-1;
            break;
        else
            if ~isnan(tmpFlag)
                % absolute time
                h.IOData.formatcell.rowIsAbsTime=tmpFlag;
                break;
            end
        end
    end
else
    if ischar(data)
        tmpFlag=h.IsTimeFormat(data);
        if ~isnan(tmpFlag)
            h.IOData.formatcell.rowIsAbsTime=tmpFlag;
        end
    end
    if isnumeric(data)
        h.IOData.formatcell.rowIsAbsTime=-1;
    end
end
h.IOData.formatcell.rowIndex=0;
h.IOData.formatcell.rowIndex=index;
h.IOData.formatcell.name=name;

