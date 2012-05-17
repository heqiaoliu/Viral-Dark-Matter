function tsExcelActiveXCellActivate(h,varargin) 
% TSEXCELACTIVEXCELLACTIVATE is the callback for 'selectionchange' action

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

% make sure it is selection change
if ~strcmp(varargin{end}, 'SelectionChange')
    return
end
% get handle to the excelImportdlg
% h=varargin{1}.handle;
% get starting row and column number from ActX
selcolumn=varargin{1}.Selection.column;
selrow=varargin{1}.Selection.row;
% get valid block size and treat single cell separately
Address = varargin{1}.Selection.Address;
DollarNumber=size(findstr('$',Address),2);
[StartCell tmp]=strtok(Address,':');
EndCell=strtok(tmp,':');
if isempty(EndCell)
    % single cell selection
    selsize=[1,1];
elseif DollarNumber == 4
    [startColumnStr startTmp] = strtok(StartCell,'$');
    [endColumnStr endTmp] = strtok(EndCell,'$');
    startColumnNumber = h.findcolumnnumber(startColumnStr);
    endColumnNumber = h.findcolumnnumber(endColumnStr);
    startRowNumber = str2num(strtok(startTmp,'$'));
    endRowNumber = str2num(strtok(endTmp,'$'));
    selsize = [endRowNumber-startRowNumber+1 endColumnNumber-startColumnNumber+1];
%     try
%         tmpValue=varargin{1}.Selection.Value;
%         if iscell(tmpValue)
%             % more than multiple cells
%             selsize=size(tmpValue);
%         else
%             % single cell
%             selsize=[1,1];
%         end
%     catch
%         % it is in the 'select all' situation if Selection.Value returns error
%         selsize=h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,:)
%     end
elseif DollarNumber == 2
    startStr = strtok(StartCell,'$');
    endStr = strtok(EndCell,'$');
    if isempty(str2num(startStr)) || isempty(str2num(endStr))
        % column-wise selection
        startColumnNumber = h.findcolumnnumber(startStr);
        endColumnNumber = h.findcolumnnumber(endStr);
        startRowNumber = 1;
        endRowNumber = h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,1);
        selsize = [endRowNumber-startRowNumber+1 endColumnNumber-startColumnNumber+1];
    else
        % row-wise selection
        startColumnNumber = 1;
        endColumnNumber = h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,2);
        startRowNumber = str2num(strtok(startStr,'$'));
        endRowNumber = min(str2num(strtok(endStr,'$')),h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,1));
        selsize = [endRowNumber-startRowNumber+1 endColumnNumber-startColumnNumber+1];
    end
end

% deal with the first column/row for smart selection
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    if selrow==1
        % first row is selected
        ignored=h.IgnoreFirstColumnRow;
        if ignored>0
            selrow=ignored+1;
            selsize(1)=selsize(1)-ignored;
%             if ignored==h.IOData.checkLimit
%                 msgbox(sprintf('The first %d time points are invalid.  Auto-selection starts from the %d time point',...
%                     h.IOData.checkLimit,h.IOData.checkLimit+1),'Time Series Tools');
%             end
        end
    end
else
    % time vector is stored as a row
    if selcolumn==1
        % first row is selected
        ignored=h.IgnoreFirstColumnRow;
        if ignored>0
            selcolumn=ignored+1;
            selsize(2)=selsize(2)-ignored;
%             if ignored==h.IOData.checkLimit
%                 msgbox(sprintf('The first %d time points are invalid.  Auto-selection starts from the %d time point',...
%                     h.IOData.checkLimit,h.IOData.checkLimit+1),'Time Series Tools');
%             end
        end
    end
end

% if the end of the selected block is beyond the UsedRange, use the
% UsedRange as the end of the block instead
% tmp=size(varargin{1}.ActiveSheet.UsedRange.Value);
if get(h.Handles.COMBdataSample,'Value')==1
    if selrow>h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,1)
        % starting row exceeds the used range, which means no time point
        selrow=h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,1);
        selsize(1)=1;
    else
        selsize(1)=min(selrow+selsize(1)-1,h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,1))-selrow+1;
    end
    % selsize(2)=max(1,min(selcolumn+selsize(2)-1,size(varargin{1}.ActiveSheet.UsedRange.Value,2))-selcolumn+1);
else
    % selsize(1)=max(1,min(selrow+selsize(1)-1,size(varargin{1}.ActiveSheet.UsedRange.Value,1))-selrow+1);
    if selcolumn>h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,2)
        % starting column exceeds the used range, which means no time point
        selcolumn=h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,2);
        selsize(2)=1;
    else
        selsize(2)=min(selcolumn+selsize(2)-1,h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,2))-selcolumn+1;
    end
end

% update selected block parameters
h.IOData.SelectedColumns=selcolumn:selcolumn+selsize(2)-1;
h.IOData.SelectedRows=selrow:selrow+selsize(1)-1;
% update displays in the editboxes
set(h.Handles.EDTFROM,'String',[h.findcolumnletter(selcolumn) num2str(selrow)]);
set(h.Handles.EDTTO,'String',[h.findcolumnletter(selcolumn+selsize(2)-1) num2str(selrow+selsize(1)-1)]);
% check if a valid time vector exists (first and last elements)
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    h.updateStartEndTime(selrow,selrow+selsize(1)-1);
else
    % time vector is stored as a row
    h.updateStartEndTime(selcolumn,selcolumn+selsize(2)-1);
end
% update display
if selsize(1)>0 && selsize(2)>0
    if ~isempty(h.Handles.ActiveX.eventlisteners)
        h.Handles.ActiveX.unregisterallevents;
    end
    tmpStr=strcat(h.findcolumnletter(selcolumn),num2str(selrow),':',h.findcolumnletter(selcolumn+selsize(2)-1),num2str(selrow+selsize(1)-1));
    h.Handles.ActiveX.ActiveSheet.Range(tmpStr).Select;
    h.Handles.ActiveX.registerevent({'SelectionChange' @(a,b,c,d) tsExcelActiveXCellActivate(h,a,b,c,d); ...
        'EndEdit' @(a,b,c,d,e,f,g,j) tsExcelActiveXCellEdit(h,a,b,c,d,e,f,g,j); ...
        'SheetActivate' @(a,b,c,d,e) tsExcelActiveXSheetActivate(h,a,b,c,d,e)});
end

