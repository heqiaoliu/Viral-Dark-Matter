function checkTimeFormat(h,name,colrow,indexStr)
% CHECKTIMEFORMAT checks the time format of the given row and/or column and
% update the information stored in 'h.IOData.formatcell' struct

% stored information
%   name: string, checked active sheet name
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
% Revised: 
% Copyright 1986-2006 The MathWorks, Inc.

% this function is only called when ActiveX web component is available
if isempty(h.Handles.ActiveX)
    return
end
sheet = get(h.Handles.originalSheets,'Item',name);
SheetSize = h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,:);

if strcmp(colrow,'column')
    % check a column
    % get column index
    index=h.findcolumnnumber(indexStr);
    % check if recheck is necessary
    if ~isempty(index)
        if h.IOData.formatcell.columnIndex~=index || ~strcmp(h.IOData.formatcell.name,name)
            % check and update
            if ~isinf(h.IOData.formatcell.columnIsAbsTime)
                localCheckColumn(h,name,index,SheetSize);
            end
        end
    end
elseif strcmp(colrow,'row')
    % check a row
    try
        % get row index
        index=str2double(indexStr);
    catch
        return
    end
    % check if recheck is necessary
    if h.IOData.formatcell.rowIndex~=index || ~strcmp(h.IOData.formatcell.name,name)
        % check and update
        if ~isinf(h.IOData.formatcell.rowIsAbsTime)
            localCheckRow(h,name,index,SheetSize);
        end
    end
elseif strcmp(colrow,'both')
    % only called once at the initialization stage
    % get index
    index=str2double(indexStr);
    % try column
    tmpFormat = localCheckColumn(h,name,index,SheetSize);
    % try row
    if isnan(h.IOData.formatcell.columnIsAbsTime) && ~strcmp(tmpFormat,'cancel')
        localCheckRow(h,name,index,SheetSize);
    else
        h.IOData.formatcell.rowIsAbsTime=NaN;
        h.IOData.formatcell.rowFormat={''};
        h.IOData.formatcell.columnIndex=0;
        h.IOData.formatcell.rowIndex=index;
        h.IOData.formatcell.name=name;
    end
end
          

function tmpFormat = localCheckColumn(h,name,index,SheetSize)
% check time format for a column and store information into formatcell

% get sheet from the original excel workbook
sheet = get(h.Handles.originalSheets,'Item',name);
% initialize flag storage
h.IOData.formatcell.columnIsAbsTime=NaN;
h.IOData.formatcell.columnFormat={''};
% get column letter
columnLetter=h.findcolumnletter(index+sheet.UsedRange.Column-1);
% check each cell until reaches checkLimit
% be careful with the usedrange offsets
for i=min(SheetSize(1),h.IOData.checkLimit):-1:1
    % get numberformat
    tmpstr=[columnLetter num2str(i+sheet.UsedRange.Row-1)];
    readinfo=get(sheet,'Range',tmpstr);
    tmpcell={sheet.Range(tmpstr).NumberFormat};
    % Call to .Value may fail for some weird cell entries, e.g. #NULL
    % due to error out of ActiveX control
    try
        CellValue = readinfo.Value;
    catch
        CellValue = NaN;
    end
    % if it is date/time, set the flag true
    [tmpFlag, dummy, tmpFormat]=h.IsTimeFormat(tmpcell,{CellValue},columnLetter,'col');
    if tmpFlag<0 || strcmp(tmpFormat,'cancel')
        % relative time
        h.IOData.formatcell.columnIsAbsTime=-1;
        h.IOData.formatcell.columnFormat={'General'};
        break;
    else
        if ~isnan(tmpFlag)
            % absolute time with customerized format
            h.IOData.formatcell.columnIsAbsTime=tmpFlag;
            h.IOData.formatcell.columnFormat={tmpFormat};
            break;
        end
    end
end
h.IOData.formatcell.columnIndex=index;
h.IOData.formatcell.rowIndex=0;
h.IOData.formatcell.name=name;


function tmpFormat = localCheckRow(h,name,index,SheetSize)
% check time format for a row and store information into formatcell

% get sheet from the original excel workbook
sheet = get(h.Handles.originalSheets,'Item',name);
% initialize flag storage
h.IOData.formatcell.rowIsAbsTime=NaN;
h.IOData.formatcellrowFormat={''};
% get row number
rowNumber=num2str(index+sheet.UsedRange.Row-1);
% check each cell until reaches checkLimit
% be careful with the usedrange offsets
for i=min(SheetSize(2),h.IOData.checkLimit):-1:1
    % get numberformat
    tmpstr=[h.findcolumnletter(i+sheet.UsedRange.Column-1) rowNumber];
    readinfo=get(sheet,'Range',tmpstr);
    tmpcell={readinfo.NumberFormat};
    % Call to .Value may fail for some weird cell entries, e.g. #NULL
    % due to error out of ActiveX control
    try
        CellValue = readinfo.Value;
    catch
        CellValue = NaN;
    end
    % if it is date/time, set the flag true
    [tmpFlag, dummy, tmpFormat]=h.IsTimeFormat(tmpcell,{CellValue},rowNumber,'row');
    if tmpFlag<0 || strcmp(tmpFormat,'cancel')
        % relative time
        h.IOData.formatcell.rowIsAbsTime=-1;
        h.IOData.formatcell.rowFormat={'General'};
        break;
    else
        if ~isnan(tmpFlag)
            h.IOData.formatcell.rowIsAbsTime=tmpFlag;
            h.IOData.formatcell.rowFormat=tmpFormat;
            break;
        end
    end
end
h.IOData.formatcell.columnIndex=0;
h.IOData.formatcell.rowIndex=index;
h.IOData.formatcell.name=name;

