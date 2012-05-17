function flag=initialize(h,filename)
% INITIALIZE is the function that tstool uses to display the import dialog
% given full path of the file in the 'filename' parameter.

% 1. the import dialog is resizable.
% 2. if the filename is the same as the last one, just display the import
%    dialog without reloading the file, otherwise, load the new file and
%    refresh the dialog.

% Author: Rong Chen 
%  Copyright 2004-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.9 $ $Date: 2010/05/13 17:42:50 $

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
h.defaultPositions;

% -------------------------------------------------------------------------
% if using ActiveX control for display, create webcomponent connection
% every time 
% -------------------------------------------------------------------------
if ~isempty(h.Handles.ActiveX)
    try
        h.Handles.WebComponent = actxserver('Excel.Application');
        h.Handles.WebComponent.Visible = 0;
    catch %#ok<*CTCH>
        % if error, use uitable for display
        h.Handles.ActiveX=[];
        h.Handles.WebComponent=[];
    end       
end


% -------------------------------------------------------------------------
%% check if the same file is to be opened 
% -------------------------------------------------------------------------
if strcmp(h.IOData.FileName,filename)
    % the input filename is the same as h.IOData.ExcelFileName
    if ~isempty(h.Handles.ActiveX)
        % activex web component should be available
        h.Handles.ActiveX.move([h.DefaultPos.Table_leftoffset ...
                                h.DefaultPos.Table_bottomoffset ...
                                h.DefaultPos.Table_width ...
                                h.DefaultPos.Table_height]);
        % we are going to reconnect to the excel file through the com
        % server since every time the dialog is closed the connection is
        % lost. 
        try
            % open the file connection
            h.Handles.originalWorkbooks = h.Handles.WebComponent.Workbooks;
            invoke(h.Handles.originalWorkbooks, 'open', filename);
            h.Handles.originalSheets = h.Handles.WebComponent.ActiveWorkBook.Sheets;
        catch
            % activex web component should be available. however, if we have
            % the connection problem, use uitable instead
            errordlg('Cannot connect to the Excel Workbook','Time Series Tools','modal');
            flag=false;
            return
        end
    end
    if  ~isempty(h.Handles.tsTable)
       set(h.Handles.tsTable,'Position',...
           [h.DefaultPos.Table_leftoffset ...
            h.DefaultPos.Table_bottomoffset+28 ...
            h.DefaultPos.Table_width ...
            h.DefaultPos.Table_height-28]);
    end                            
    set(h.Handles.PNLdata,'Visible','on');
    set(h.Handles.PNLtime,'Visible','on');
    % update the dialog title
    set(h.Figure,'Name',xlate(sprintf('Import Time Series From Excel (%s)',filename)));
    flag=true;
    return
end

% update the filename
h.IOData.FileName=filename;

% -------------------------------------------------------------------------
%% Initialize the internal state variables
% -------------------------------------------------------------------------
% update the dialog title
set(h.Figure,'Name',xlate(sprintf('Import Time Series From Excel (%s)',filename)));

% initialize state variables
h.IOData.checkLimitColumn=20;
h.IOData.checkLimitRow=20;
% no selection
h.IOData.SelectedColumns=[];
h.IOData.SelectedRows=[];
% no format information
h.IOData.formatcell=struct();
h.IOData.formatcell.name='';
h.IOData.formatcell.columnIndex=0;
h.IOData.formatcell.rowIndex=0;
h.IOData.formatcell.matlabFormatString = ...
    {'dd-mmm-yyyy HH:MM:SS' 'dd-mmm-yyyy' 'mm/dd/yy' 'mm/dd' 'HH:MM:SS' ...
    'HH:MM:SS PM' 'HH:MM' 'HH:MM PM' 'mmm.dd,yyyy HH:MM:SS' 'mmm.dd,yyyy' 'mm/dd/yyyy' 'custom'};
h.IOData.formatcell.matlabFormatIndex = [0 1 2 6 13 14 15 16 21 22 23 inf];
h.IOData.formatcell.matlabUnitString={'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'};

h.Handles.bar=waitbar(20/100,'Loading Excel Spreadsheet, Please Wait...');

% -------------------------------------------------------------------------
%% Build data panel
% -------------------------------------------------------------------------
flag=h.initializeDataPanel(filename);
if ~flag
    h.IOData.FileName=[];
    if ~isempty(h.Handles.WebComponent)
        try
            invoke(h.Handles.WebComponent, 'quit'); 
            invoke(h.Handles.WebComponent, 'delete'); 
        catch
            % failed to use the activex component for some reason unknown
            % errordlg('excel import dialog couldn''t connect to the excel comserver during exit','Time Series Tools');
        end
    end
    return
end
if ishandle(h.Handle.bar)
   waitbar(90/100,h.Handle.bar);
end
% -------------------------------------------------------------------------
%% Build time panel
% -------------------------------------------------------------------------
h.initializeTimePanel;
if ishandle(h.Handle.bar)
    waitbar(100/100,h.Handle.bar);
    delete(h.Handle.bar);
end


% -------------------------------------------------------------------------
%% show table
% -------------------------------------------------------------------------
if ~isempty(h.Handles.ActiveX)
    h.Handles.ActiveX.move([h.DefaultPos.Table_leftoffset ...
                        h.DefaultPos.Table_bottomoffset ...
                        h.DefaultPos.Table_width ...
                        h.DefaultPos.Table_height]);
else
    set(h.Handles.tsTablePanel,'Position', ...
        [h.DefaultPos.Table_leftoffset ...
        h.DefaultPos.Table_bottomoffset+28 ...
        h.DefaultPos.Table_width ...
        h.DefaultPos.Table_height-28]);
end

set(h.Handles.PNLdata,'Visible','on');
set(h.Handles.PNLtime,'Visible','off');
set(h.Handles.PNLDisplayWorkspaceInfo,'Title',xlate(' Selected Time Vector '));
set(h.Handles.PNLtime,'Visible','on');

% -------------------------------------------------------------------------
%% check date string format
% -------------------------------------------------------------------------
% get numberformat property for the first column and the first row,
% and the information is stored in the 'formatcell' struct.
% Note: only a limited number of cells are checked for absolute
% date/time format, or the relative time format
% check only on the active sheet when exits
h.checkTimeFormat(h.IOData.DES{1},'both','1');

% initialize dynamic panels
if  ~isempty(h.Handles.ActiveX)
    
    % set correct absolute data/time if in the 1st col or row
    if h.IOData.formatcell.columnIsAbsTime>=0
        rangeStr=strcat('A1:A',num2str(h.IOData.currentSheetSize(1,1)));
        if ~isempty(cell2mat(h.IOData.formatcell.columnFormat))
            h.Handles.ActiveX.ActiveSheet.Range(rangeStr).NumberFormat=cell2mat(h.IOData.formatcell.columnFormat);
        end
    elseif h.IOData.formatcell.rowIsAbsTime>=0
        rangeStr=strcat('A1:',h.findcolumnletter(h.IOData.currentSheetSize(1,2)),'1');
        if ~isempty(cell2mat(h.IOData.formatcell.rowFormat))
            h.Handles.ActiveX.ActiveSheet.Range(rangeStr).NumberFormat=cell2mat(h.IOData.formatcell.rowFormat);
        end
    end

    % activex
    if h.IOData.formatcell.columnIsAbsTime>=0
        % the first column contains absolute time format
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    elseif h.IOData.formatcell.rowIsAbsTime>=0
        % the first row contains absolute time format
        set(h.Handles.COMBdataSample,'Value',2);
        h.TimePanelUpdate('row');
    elseif h.IOData.formatcell.columnIsAbsTime==-1
        % the first column contains doubles which can be relative time
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    elseif h.IOData.formatcell.rowIsAbsTime==-1
        % the row column contains doubles which can be relative time
        set(h.Handles.COMBdataSample,'Value',2);
        h.TimePanelUpdate('row');
    else 
        % no time or number detected in either the first row or column
        % set column as default and bring up the manual input
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
        set(h.Handles.COMBtimeSource,'Value',2);
        set(h.Handles.PNLtimeCurrentSheet,'Visible','off');
        set(h.Handles.PNLtimeManual,'Visible','on');
    end        
end

% -------------------------------------------------------------------------
%% select all
% -------------------------------------------------------------------------
if ~isempty(h.Handles.ActiveX)
    tmpStr=strcat('A1:',...
            h.findcolumnletter(h.IOData.originalSheetSize(h.Handles.ActiveX.ActiveSheet.Index,2)),...
            num2str(h.IOData.originalSheetSize(h.Handles.ActiveX.ActiveSheet.Index,1)));
    h.Handles.ActiveX.ActiveSheet.Range(tmpStr).Select;
elseif ~isempty(h.Handles.tsTable)
    awtinvoke(h.Handles.tsTable.getTable,'selectAll');
end

