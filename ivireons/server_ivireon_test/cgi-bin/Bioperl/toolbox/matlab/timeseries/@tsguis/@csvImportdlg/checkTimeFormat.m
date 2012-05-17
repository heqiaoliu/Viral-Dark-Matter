function checkTimeFormat(h,colrow,indexStr)
% CHECKTIMEFORMAT checks the time format of the given row and/or column and
% update the information stored in 'h.IOData.formatcell' struct

% stored information
%   columnIndex: integer, checked columnindex
%   rowIndex: integer, checked rowindex
%   columnIsAbsTime: integer, a time format 
%   columnFormat: cell of string, original NumberFormat in excel
%   rowIsAbsTime: integer, a time format 
%   rowFormat: cell of string, original NumberFormat in excel
%   
%   time format:
%   -1      double values, which could be relative time points
%   >=0     absolute date/time format supported by Matlab
%   NaN     not a time format (unrecognizable), e.g. a string
%
% inputs:   name: a string of the active sheetname
%           colrow: a string of 'row', 'column', 'both'
%           index: a string of '1', '2', ... or 'A', 'B', ...

% Author: Rong Chen
% Copyright 2004-2008 The MathWorks, Inc.

if strcmp(colrow,'column')
    % Check a column, get column index
    index = h.findcolumnnumber(indexStr);
    
    % Check if recheck is necessary
    if ~isempty(index)
        if h.IOData.formatcell.columnIndex~=index 
            
            % Check and update
            if ~isinf(h.IOData.formatcell.columnIsAbsTime)
                localCheckColumn(h,index,h.IOData.currentSheetSize);
            end
        end
    end
elseif strcmp(colrow,'row')
    % Check a row
    try
        % Get row index
        index=str2double(indexStr);
    catch %#ok<CTCH>
        return
    end
    % Check if recheck is necessary
    if h.IOData.formatcell.rowIndex~=index
        % Check and update
        if ~isinf(h.IOData.formatcell.rowIsAbsTime)
            localCheckRow(h,index,h.IOData.currentSheetSize);
        end
    end
elseif strcmp(colrow,'both')
    % Only called once at the initialization stage get index
    index=str2double(indexStr);
    % Try column
    localCheckColumn(h,index,h.IOData.currentSheetSize);
    % Try row
    if isnan(h.IOData.formatcell.columnIsAbsTime)
        localCheckRow(h,index,h.IOData.currentSheetSize);
    else
        h.IOData.formatcell.rowIsAbsTime=NaN;
        h.IOData.formatcell.rowFormat={''};
        h.IOData.formatcell.columnIndex=0;
        h.IOData.formatcell.rowIndex=index;
    end
end
          

function localCheckColumn(h,index,SheetSize)
% check time format for a column and store information into formatcell

% Initialize flag storage
h.IOData.formatcell.columnIsAbsTime = NaN;
h.IOData.formatcell.columnFormat = {''};

% Check each cell until reaches checkLimit be careful with the usedrange
% offsets
formatCell = h.IOData.formatcell;
rawData = h.IOData.rawdata;
for i=min(SheetSize(1),h.IOData.checkLimit):-1:1
    %                   relative    absolute    user-defined    invalid
    %   columnIsAbsTime  -1          0/1            inf             NaN 
    %   columnFormat     {}          ****           ****            {}
    
    if isnumeric(rawData{i,index})
        formatCell.columnIsAbsTime = -1;
        formatCell.columnFormat = {};
    elseif ischar(rawData{i,index})
        try 
            datenum(rawData{i,index});
            if ~isempty(strfind(rawData{i,index},':'))
                formatCell.columnIsAbsTime = 0;
                formatCell.columnFormat = 'dd-mmm-yyyy HH:MM:SS';
                break
            else
                formatCell.columnIsAbsTime = 1;
                formatCell.columnFormat = 'dd-mmm-yyyy';
                break
            end
        catch %#ok<CTCH>
            formatCell.columnIsAbsTime = NaN;
            formatCell.columnFormat = {''};
        end
    end
end
formatCell.columnIndex = index;
if ~isnan(formatCell.columnIsAbsTime)
    h.IOData.formatcell.rowIndex = 0;
end
h.IOData.formatcell = formatCell;



function localCheckRow(h,index,SheetSize)

% Check time format for a row and store information into formatcell

% Initialize flag storage
h.IOData.formatcell.rowIsAbsTime=NaN;
h.IOData.formatcellrowFormat={''};

% Check each cell until reaches checkLimit be careful with the usedrange
% offsets
for i=min(SheetSize(2),h.IOData.checkLimit):-1:1
    
    if isnumeric(h.IOData.rawdata{index,i})
        h.IOData.formatcell.rowIsAbsTime = -1;
        h.IOData.formatcell.rowFormat = {};
    elseif ischar(h.IOData.rawdata{index,i})
        try 
            datenum(h.IOData.rawdata{index,i});
            if ~isempty(strfind(h.IOData.rawdata{index,i},':'))
                h.IOData.formatcell.rowIsAbsTime = 0;
                h.IOData.formatcell.rowFormat = 'dd-mmm-yyyy HH:MM:SS';
                break
            else
                h.IOData.formatcell.rowIsAbsTime = 1;
                h.IOData.formatcell.rowFormat = 'dd-mmm-yyyy';
                break
            end
        catch %#ok<CTCH>
            h.IOData.formatcell.rowIsAbsTime = NaN;
            h.IOData.formatcell.rowFormat = {''};
        end
    end
end
h.IOData.formatcell.columnIndex = 0;
h.IOData.formatcell.rowIndex = index;

