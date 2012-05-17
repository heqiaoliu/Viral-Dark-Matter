function flag=initializeDataPanel(h, FileName)
% INITIALIZEDATAPANEL initializes the 'Select Data to Import' panel, which
% contains either an activex control or a uitable for spreadsheet display,
% as well as a few other uicontrols

% Author: Rong Chen 
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.11 $ $Date: 2008/12/29 02:11:10 $

% -------------------------------------------------------------------------
%% Build data panel
%
% Note that: currently we only support single block data selection from the
% excel sheet.  The reason is that: 1. the mouse operation provided by the
% activex control only allows to select a single block; 2. the absolute
% time format results in a very complicated parser for the edit boxes if
% multuiple blocks are allowed.  So, if user has discontinuous blocks, he
% can either merge them in excel before importing or create multiple
% timeseries during the import stage and then merge them later in tstool.
% -------------------------------------------------------------------------
h.DefaultPos.DataPanelDefaultColor=h.DefaultPos.FigureDefaultColor;
if isfield(h.Handles,'PNLdata') && ishghandle(h.Handles.PNLdata)
    delete(h.Handles.PNLdata);
end
h.Handles.PNLdata = uipanel('Parent',h.Figure, ...
    'Units','Pixels', ...
    'FontSize',9,...
    'FontWeight','bold', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor,...
    'Position', [h.DefaultPos.leftoffsetpnl ...
                 h.DefaultPos.bottomoffsetDatapnl ...
                 h.DefaultPos.widthpnl ...
                 h.DefaultPos.heightDatapnl], ...
    'Title',xlate(' Specify data '),...
    'Visible','off'...
);
% h.Handles.PNLdata = handle(h.Handles.PNLdata);

% -------------------------------------------------------------------------
%% display spreadsheet 
% -------------------------------------------------------------------------
if ~isempty(h.Handles.WebComponent)
    % activex is used
    try
        % open the file connection
        h.Handles.originalWorkbooks = h.Handles.WebComponent.Workbooks;
        invoke(h.Handles.originalWorkbooks, 'open', FileName);
        h.Handles.originalSheets = h.Handles.WebComponent.ActiveWorkBook.Sheets;
    catch
        % activex web component should be available. however, if we have
        % the connection problem, use uitable instead
        try
            delete(h.Handles.ActiveX);
            invoke(h.Handles.WebComponent, 'quit'); 
            invoke(h.Handles.WebComponent, 'delete'); 
            h.Handles.ActiveX=[];
            h.Handles.WebComponent=[];    
        catch
            h.Handles.ActiveX=[];
            h.Handles.WebComponent=[];    
        end
    end
end

if isempty(h.Handles.ActiveX)
    % when activex is not available, uitable is created instead
    %%%% This call works with the undocumented version of uitable which
    %%%% can be found in uitools\private\uitable_deprecated.m.  This
    %%%% functionality will be removed in a future release.  
    %%%%
    %%%% To migrate to the supported uitable, use the following call:
    %%%%   h.Handles.ts.Table = uitable(h.Figure);
    %%%%
    %%%% Note that the container h.Handles.ts.TablePanel is no longer
    %%%% available.
   [h.Handles.tsTable, h.Handles.tsTablePanel] = uitable('v0', h.Figure);
   
   %%%% The container is no lonter available, but these properties can be
   %%%% set on the table directly:
   %%%%  set(h.Handles.tsTable,'Units','Pixels','Position', ...
   %%%%     [0 0 1 1], ...
   %%%%     'BackgroundColor',h.DefaultPos.DataPanelDefaultColor);
   set(h.Handles.tsTablePanel,'Units','Pixels','Position', ...
        [0 0 1 1], ...
        'BackgroundColor',h.DefaultPos.DataPanelDefaultColor);
    
    % set(h.Handles.tsTable.TableScrollPane,'Background',h.DefaultPos.DataPanelDefaultColor);
    % prevent reordering the column
    %%%% This statement is currently not migratable.
    h.Handles.tsTable.getTable.getTableHeader().setReorderingAllowed(false);
    
    % create time unit popupmenu control
    h.Handles.TXTdataSheet = uicontrol('Parent',h.Handles.PNLdata,...
        'style','text',...
        'Units','Pixels',...
        'BackgroundColor',h.DefaultPos.DataPanelDefaultColor,...
        'String',xlate('Sheet :'),...
        'HorizontalAlignment','Left',...
        'Position',[h.DefaultPos.TXTdataSampleleftoffset 80-4 h.DefaultPos.TXTdataSamplewidth h.DefaultPos.heighttxt] ...
        );
    h.Handles.COMBdataSheet = uicontrol('Parent',h.Handles.PNLdata,...
        'style','popupmenu',...
        'Units','Pixels',...
        'String',' ',...
        'Value',1,...
        'Position',[h.DefaultPos.COMBdataSampleleftoffset 80 h.DefaultPos.COMBdataSamplewidth h.DefaultPos.heightcomb], ...
        'Callback',{@localUITableSheetChanged h});
    if ~ismac
       set(h.Handles.COMBdataSheet,'BackgroundColor',[1 1 1]);
    end
end

if ~isempty(h.Handles.ActiveX)
    % populate the activex control using the data from the import file
    if ~isempty(h.Handles.ActiveX.eventlisteners)
        h.Handles.ActiveX.unregisterallevents;
    end
    flag=h.ReadExcelFile(FileName);
    if ~flag
        return
    end    
    % use the active sheet name as the default time series object name
    set(h.Parent.Handles.EDTsingleNEW,'String',h.Handles.ActiveX.ActiveSheet.Name);
    % set callback after read in the excel file
    % h.Handles.ActiveX.registerevent({'SelectionChange' @tsExcelActiveXCellActivate; 'SheetActivate' @tsExcelActiveXSheetActivate});
    h.Handles.ActiveX.registerevent({'SelectionChange' @(a,b,c,d) tsExcelActiveXCellActivate(h,a,b,c,d); ...
        'EndEdit' @(a,b,c,d,e,f,g,j) tsExcelActiveXCellEdit(h,a,b,c,d,e,f,g,j); ...
        'SheetActivate' @(a,b,c,d,e) tsExcelActiveXSheetActivate(h,a,b,c,d,e)});
elseif ~isempty(h.Handles.tsTable)
    % populate the uitable using the data from the import file
    flag=h.ReadExcelFile(FileName);
    if ~flag
        return
    end    
    % use the active sheet name as the default time series object name
    strCell=get(h.Handles.COMBdataSheet,'String');
    set(h.Parent.Handles.EDTsingleNEW,'String',strCell{get(h.Handles.COMBdataSheet,'Value')});
    
    % register callback
    %%%% These statements are currently not migratable.
    set(handle(h.Handles.tsTable.getTable.getSelectionModel,'callbackproperties'),'ValueChangedCallback',{@localUITableDataChanged h 'row'});
    set(handle(h.Handles.tsTable.getTable.getColumnModel.getSelectionModel,'callbackproperties'),'ValueChangedCallback',{@localUITableDataChanged h 'column'});
else
    errordlg('Cannot create a time series data table. Unable to import.',...
        'Time Series Tools','modal');
    delete(h.Handle.bar);
    flag=false;
    return;
end

% -------------------------------------------------------------------------
%% create all the other ui controls in the data panel
% -------------------------------------------------------------------------
% add column and row edit boxes, static texts and radio buttons
huicTXTdataSample = uicontextmenu('Parent',h.Figure);
h.Handles.TXTdataSample = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',xlate('Data is arranged by : '), ...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTdataSample,...
    'Position',[h.DefaultPos.TXTdataSampleleftoffset ...
                h.DefaultPos.TXTdataSamplebottomoffset ...
                h.DefaultPos.TXTdataSamplewidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTdataSample,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_data_arranged_by'',''modal'')')

h.Handles.COMBdataSample = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','popupmenu', ...
    'Units','Pixels', ...
    'String',[{xlate('columns')},{xlate('rows')}], ...
    'Value',1,...
    'TooltipString',xlate('If data in the current variable is organized by column, select ''columns'', otherwise select ''rows''.'), ...
    'Position',[h.DefaultPos.COMBdataSampleleftoffset ...
                h.DefaultPos.TXTdataSamplebottomoffset+4 ...
                h.DefaultPos.COMBdataSamplewidth ...
                h.DefaultPos.heightcomb], ...
    'Callback',{@localSwitchSample h} ...
    );
if ~ismac
    set(h.Handles.COMBdataSample,'BackgroundColor',[1 1 1]);
end

huicTXTblock = uicontextmenu('Parent',h.Figure);
h.Handles.TXTblock = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',xlate('Data block is defined by : '), ...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTblock,...
    'Position',[h.DefaultPos.TXTdataleftoffset ...
                h.DefaultPos.TXTdatabottomoffset ...
                h.DefaultPos.TXTdatawidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTblock,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_select_data_xls'',''modal'')')

h.Handles.TXTFROM = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',xlate('Top-left cell'), ...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTfromleftoffset ...
                h.DefaultPos.TXTdatabottomoffset ...
                h.DefaultPos.TXTfromwidth ...
                h.DefaultPos.heighttxt] ...
    );
h.Handles.EDTFROM = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','edit', ...
    'Units','Pixels', ...
    'BackgroundColor',[1 1 1],...
    'String','', ...
    'TooltipString',xlate('Key in the top-left corner of the desired block, using MS Excel A1 reference style (e.g. A12).'), ...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.EDTfromleftoffset ...
                h.DefaultPos.TXTdatabottomoffset+2 ...
                h.DefaultPos.EDTfromwidth ...
                h.DefaultPos.heightedt],...
    'Callback',{@localChangeBlock h 'FROM'} ...
    );
h.Handles.TXTTO = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',xlate('Bottom-right cell'), ...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTtoleftoffset ...
                h.DefaultPos.TXTdatabottomoffset ...
                h.DefaultPos.TXTtowidth ...
                h.DefaultPos.heighttxt] ...
    );
h.Handles.EDTTO = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','edit', ...
    'Units','Pixels', ...
    'BackgroundColor',[1 1 1],...
    'String','',...
    'TooltipString',xlate('Key in the bottom-right corner of the desired block, using MS Excel A1 reference style (e.g. B34).'), ...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.EDTtoleftoffset ...
                h.DefaultPos.TXTdatabottomoffset+2 ...
                h.DefaultPos.EDTtowidth ...
                h.DefaultPos.heightedt],...
    'Callback',{@localChangeBlock h 'TO'} ...
    );

% -------------------------------------------------------------------------
%% common callbacks
% -------------------------------------------------------------------------
function localSwitchSample(eventSrc, eventData, h)
% callback for COMBdataSample (Switch : a sample is a row or a column)
% change some disaply
if get(h.Handles.COMBdataSample,'Value')==1
    localSetHEAD(h,'row');    
    % time vector is stored as a column
    if ~isempty(h.IOData.SelectedRows)
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    end
else
    localSetHEAD(h,'column');    
    % time vector is stored as a row
    if ~isempty(h.IOData.SelectedColumns)
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    end
end


function localChangeBlock(eventSrc, eventData, h, token)
% callback for the editbox in the data panel
% 'token' parameter accepts 'FROM' and 'TO'

% get string from the FROM editbox
tmpStr=strtrim(get(h.Handles.EDTFROM,'String'));
% separate letters and number
[columnStr, rowStr]=strtok(tmpStr,'1234567890');
if isempty(columnStr) && isempty(rowStr)
    return
end
first_column=h.findcolumnnumber(columnStr);
first_row=str2double(rowStr);
if (isempty(first_column) || isnan(first_row)) && strcmp(token,'FROM')
    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
        set(eventSrc,'String','');
    else
        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
        localUpdateTableDisplay(h);
    end
    msgbox(xlate('Use standard Excel cell indexing format, e.g. A12'),'Time Series Tools');
    return
end
% get string from the TO editbox
tmpStr=strtrim(get(h.Handles.EDTTO,'String'));
% separate letters and number
[columnStr, rowStr]=strtok(tmpStr,'1234567890');
if isempty(columnStr) && isempty(rowStr)
    return
end
last_column=h.findcolumnnumber(columnStr);
last_row=str2double(rowStr);
if (isempty(last_column) || isnan(last_row)) && strcmp(token,'TO')
    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
        set(eventSrc,'String','');
    else
        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
        localUpdateTableDisplay(h);
    end
    msgbox(xlate('Use standard Excel cell indexing format, e.g. A12'),'Time Series Tools');
    return
end
% get block size and check if it is a valid block    
if ~isempty(h.Handles.ActiveX)
    eActiveSheet = h.Handles.ActiveX.ActiveSheet;
    SheetSize = h.IOData.currentSheetSize(eActiveSheet.Index,:);
    if first_column>SheetSize(2)
        first_column=SheetSize(2);
    end
    if first_row>SheetSize(1)
        first_row=SheetSize(1);
    end
    set(h.Handles.EDTFROM,'String',[h.findcolumnletter(first_column) num2str(first_row)]);
    if last_column>SheetSize(2)
        last_column=SheetSize(2);
    end
    if last_row>SheetSize(1)
        last_row=SheetSize(1);
    end
    set(h.Handles.EDTTO,'String',[h.findcolumnletter(last_column) num2str(last_row)]);
    % deal with the first column/row for smart selection
    selfirst_column=min(first_column,last_column);
    sellast_column=max(first_column,last_column);
    if get(h.Handles.COMBdataSample,'Value')==2
        % time vector is stored as a row
        if selfirst_column==1
            % first row is selected
            ignored=h.IgnoreFirstColumnRow;
            if ignored>0
                if sellast_column==selfirst_column
                    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                        % no previous selection
                        set(eventSrc,'String','');
                    else
                        % reset to previous selection
                        if strcmp(token,'FROM')
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                        else
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                        end
                        localUpdateTableDisplay(h);
                    end
                    return
                else
                    selfirst_column=ignored+1;
                    sellast_column=max(sellast_column,selfirst_column);
                end
                if ignored==h.IOData.checkLimit
                    msgbox(sprintf('The first %d time values are invalid.  Auto-selection starts from row %d.',...
                        h.IOData.checkLimit,h.IOData.checkLimit+1),'Time Series Tools');
                end
            end
        end
    end
    h.IOData.SelectedColumns=(selfirst_column:sellast_column)';
    % deal with the first column/row for smart selection
    selfirst_row=min(first_row,last_row);
    sellast_row=max(first_row,last_row);
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        if selfirst_row==1
            % first row is selected
            ignored=h.IgnoreFirstColumnRow;
            if ignored>0
                if sellast_row==selfirst_row
                    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                        set(eventSrc,'String','');
                    else
                        if strcmp(token,'FROM')
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                        else
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                        end
                        localUpdateTableDisplay(h);
                    end
                    return
                else
                    selfirst_row=ignored+1;
                    sellast_row=max(sellast_row,selfirst_row);
                end
                if ignored==h.IOData.checkLimit
                    msgbox(sprintf('The first %d time values are invalid.  Auto-selection starts from row %d.',...
                        h.IOData.checkLimit,h.IOData.checkLimit+1),'Time Series Tools');
                end
            end
        end
    end
    h.IOData.SelectedRows=(selfirst_row:sellast_row)';
    % refresh edit boxes
    if strcmp(token,'FROM')
        set(h.Handles.EDTFROM,'String',[h.findcolumnletter(selfirst_column) num2str(h.IOData.SelectedRows(1))]);
        set(h.Handles.EDTTO,'String',[h.findcolumnletter(sellast_column) num2str(h.IOData.SelectedRows(end))]);
    else
        set(h.Handles.EDTFROM,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(selfirst_row)]);
        set(h.Handles.EDTTO,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(sellast_row)]);
    end        
    localUpdateTableDisplay(h);
else
    % uitable is used
    tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));
    if first_column>size(tmpSheet,2)
        first_column=size(tmpSheet,2);
    end
    if first_row>size(tmpSheet,1)
        first_row=size(tmpSheet,1);
    end
    set(h.Handles.EDTFROM,'String',[h.findcolumnletter(first_column) num2str(first_row)]);
    if last_column>size(tmpSheet,2)
        last_column=size(tmpSheet,2);
    end
    if last_row>size(tmpSheet,1)
        last_row=size(tmpSheet,1);
    end
    set(h.Handles.EDTTO,'String',[h.findcolumnletter(last_column) num2str(last_row)]);
    % deal with the first column/row for smart selection
    selfirst_column=min(first_column,last_column);
    sellast_column=max(first_column,last_column);
    if get(h.Handles.COMBdataSample,'Value')==2
        % time vector is stored as a row
        if selfirst_column==1
            % first row is selected
            ignored=h.IgnoreFirstColumnRow;
            if ignored>0
                if sellast_column==selfirst_column
                    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                        set(eventSrc,'String','');
                    else
                        if strcmp(token,'FROM')
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                        else
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                        end
                        localUpdateTableDisplay(h);
                    end
                    return
                else
                    selfirst_column=ignored+1;
                    sellast_column=max(sellast_column,selfirst_column);
                end
                if ignored==h.IOData.checkLimit
                    msgbox(sprintf('The first %d time values are invalid.  Auto-selection starts from row %d.',...
                        h.IOData.checkLimit,h.IOData.checkLimit+1),'Time Series Tools');
                end
            end
        end
    end
    h.IOData.SelectedColumns=(selfirst_column:sellast_column)';
    % deal with the first column/row for smart selection
    selfirst_row=min(first_row,last_row);
    sellast_row=max(first_row,last_row);
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        if selfirst_row==1
            % first row is selected
            ignored=h.IgnoreFirstColumnRow;
            if ignored>0
                if sellast_row==selfirst_row
                    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                        set(eventSrc,'String','');
                    else
                        if strcmp(token,'FROM')
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                        else
                            set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                        end
                        localUpdateTableDisplay(h);
                    end
                    return
                else
                    selfirst_row=ignored+1;
                    sellast_row=max(sellast_row,selfirst_row);
                end
                if ignored==h.IOData.checkLimit
                    msgbox(sprintf('The first %d time values are invalid.  Auto-selection starts from row %d.',...
                        h.IOData.checkLimit,h.IOData.checkLimit+1),'Time Series Tools');
                end
            end
        end
    end
    h.IOData.SelectedRows=(selfirst_row:sellast_row)';
    % refresh edit boxes
    if strcmp(token,'FROM')
        set(h.Handles.EDTFROM,'String',[h.findcolumnletter(selfirst_column) num2str(h.IOData.SelectedRows(1))]);
        set(h.Handles.EDTTO,'String',[h.findcolumnletter(sellast_column) num2str(h.IOData.SelectedRows(end))]);
    else
        set(h.Handles.EDTFROM,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(selfirst_row)]);
        set(h.Handles.EDTTO,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(sellast_row)]);
    end        
    localUpdateTableDisplay(h);
end
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    if ~isempty(h.IOData.SelectedRows)
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    else
        set(h.Handles.EDTtimeSheetStart,'String','');
        set(h.Handles.EDTtimeSheetEnd,'String','');
    end
else
    % time vector is stored as a row
    if ~isempty(h.IOData.SelectedColumns)
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    else
        set(h.Handles.EDTtimeSheetStart,'String','');
        set(h.Handles.EDTtimeSheetEnd,'String','');
    end
end


function localUpdateTableDisplay(h) 
% activex control is used
if ~isempty(h.Handles.ActiveX)
    % change highlights in the activex control when editboxes are changed
    if ~isempty(h.Handles.ActiveX.eventlisteners)
        h.Handles.ActiveX.unregisterallevents;
    end
    if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
        tmpStr=strcat(h.findcolumnletter(h.IOData.SelectedColumns(1)),num2str(h.IOData.SelectedRows(1)),':',...
            h.findcolumnletter(h.IOData.SelectedColumns(end)),num2str(h.IOData.SelectedRows(end)));
        h.Handles.ActiveX.ActiveSheet.Range(tmpStr).Select;
    end
    %h.Handles.ActiveX.registerevent({'SelectionChange' @tsExcelActiveXCellActivate; 'SheetActivate' @tsExcelActiveXSheetActivate});
    h.Handles.ActiveX.registerevent({'SelectionChange' @(a,b,c,d) tsExcelActiveXCellActivate(h,a,b,c,d); ...
        'EndEdit' @(a,b,c,d,e,f,g,j) tsExcelActiveXCellEdit(h,a,b,c,d,e,f,g,j); ...
        'SheetActivate' @(a,b,c,d,e) tsExcelActiveXSheetActivate(h,a,b,c,d,e)});
% uitable is used
else
    %%%% These statements are currently not migratable.
    if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
        rowSelection = double(h.Handles.tsTable.getTable.getSelectedRows);
        colSelection = double(h.Handles.tsTable.getTable.getSelectedColumns);
        % Change highlights avoiding creating a circular reference
        if (min(colSelection)~=h.IOData.SelectedColumns(1)-1) || ...
                (max(colSelection)~=h.IOData.SelectedColumns(end)-1)
              awtinvoke(h.Handles.tsTable.getTable,'addColumnSelectionInterval',...
                  h.IOData.SelectedColumns(1)-1,h.IOData.SelectedColumns(end)-1);
        end
        if (min(rowSelection)~=(h.IOData.SelectedRows(1)-1)) || ...
            (max(rowSelection)~=(h.IOData.SelectedRows(end)-1))
              awtinvoke(h.Handles.tsTable.getTable,'addRowSelectionInterval',...
                  h.IOData.SelectedRows(1)-1,h.IOData.SelectedRows(end)-1);
              if abs(max(rowSelection)-(h.IOData.SelectedRows(end)-1))>30
                 awtinvoke(h.Handles.tsTable.getTable,'scrollRectToVisible',...
                    h.Handles.tsTable.getTable.getCellRect(h.IOData.SelectedRows(end)-1,...
                    h.IOData.SelectedColumns(end)-1,true));
              end
        end

        h.Handles.tsTable.getTable.repaint;
    end
end


function localSetHEAD(h,str) 
% change combobox contents in the tab panel
if strcmpi(str,'row')
    % a sample is a row
    huicTXTmultipleNEW = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTmultipleNEW,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_name_ts_from_row'',''modal'')')
    set(h.Parent.Handles.TXTmultipleNEW,'String',xlate('Specify row : '),'UIContextMenu',huicTXTmultipleNEW);
    set(h.Parent.Handles.EDTmultipleNEW,'String','1');
    h.TimePanelUpdate('column');
else
    % a sample is a column
    huicTXTmultipleNEW = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTmultipleNEW,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_name_ts_from_column_xls'',''modal'')')
    set(h.Parent.Handles.TXTmultipleNEW,'String',xlate('Specify column : '),'UIContextMenu',huicTXTmultipleNEW);
    set(h.Parent.Handles.EDTmultipleNEW,'String','A');
    h.TimePanelUpdate('row');
end


% -------------------------------------------------------------------------
%% ActiveX callbacks
% -------------------------------------------------------------------------
% global functions

% -------------------------------------------------------------------------
%% uitable function and callbacks
% -------------------------------------------------------------------------
function localUITableSheetChanged(eventSrc, eventData, h)
% reset table contents
%%%% NumRows and NumColumns are not available and are set by the size of
%%%% the data.  So these can probably be deleted if the data to be set is
%%%% the statement below.
set(h.Handles.tsTable,'NumRows',h.IOData.originalSheetSize(get(eventSrc,'Value'),1));
set(h.Handles.tsTable,'NumColumns',h.IOData.originalSheetSize(get(eventSrc,'Value'),2));

%%%% Java-like syntax is not available, use this instead:
%%%%   set(h.Handles.tsTable, 'Data', h.IOData.rawdata.(genvarname(h.IOData.DES{get(eventSrc,'Value')}));
h.Handles.tsTable.setData(h.IOData.rawdata.(genvarname(h.IOData.DES{get(eventSrc,'Value')})));

% clear selection
%%%% This is currently unavailable.
awtinvoke(h.Handles.tsTable.getTable,'clearSelection');

h.ClearEditBoxes;
% update time panel
% note: in this situation, no smart time vector detection for the first row
% or column.  the default time vector is along the first column
set(h.Handles.COMBdataSample,'Value',1);
h.TimePanelUpdate('column');
% use the active sheet name as the default time series object name
strCell=get(h.Handles.COMBdataSheet,'String');
set(h.Parent.Handles.EDTsingleNEW,'String',strCell{get(eventSrc,'Value')});


function localUITableDataChanged(eventSrc, eventData, h, type)
% remember in Java, index starts from 0, instead of 1

% detect whether the selection is finished
if eventSrc.valueIsAdjusting
    return
end
% get starting row and column number
if ~ishandle(h.Handles.tsTable)
    return
end

%%%% This functionality is currently not migratable.
selcolumn=h.Handles.tsTable.getTable.getSelectedColumn+1;
selrow=h.Handles.tsTable.getTable.getSelectedRow+1;
if selcolumn==0 || selrow==0
    return
end

% get valid block size and treat single cell separately
%%%% This functionality is currently not migratable.
selsize(1)=length(h.Handles.tsTable.getTable.getSelectedRows);
selsize(2)=length(h.Handles.tsTable.getTable.getSelectedColumns);

% deal with the first column/row for smart selection
ignored=0;
if get(h.Handles.COMBdataSample,'Value')==1 
    % time vector is stored as a column 
    if selrow==1 
        % first row is selected 
        ignored=h.IgnoreFirstColumnRow; 
        if ignored>0 
            selrow=ignored+1; 
            selsize(1)=selsize(1)-ignored; 
        end 
    end 
    
   %%%% This functionality is currently not migratable.
    if selrow>h.Handles.tsTable.getTable.getRowCount 
        % starting row exceeds the used range, which means no time point 
        selrow=h.Handles.tsTable.getTable.getRowCount; 
        selsize(1)=1; 
    else 
        selsize(1)=min(selrow+selsize(1)-1,h.Handles.tsTable.getTable.getRowCount)-selrow+1; 
    end 
else 
    % time vector is stored as a row 
    if selcolumn==1 
        % first row is selected 
        ignored=h.IgnoreFirstColumnRow; 
        if ignored>0 
            selcolumn=ignored+1; 
            selsize(2)=selsize(2)-ignored; 
        end 
    end 
    if selcolumn>h.Handles.tsTable.getTable.getColumnCount 
        
        % starting column exceeds the used range, which means no time point 
        %%%% This functionality is currently not migratable.
        selcolumn=h.Handles.tsTable.getTable.getColumnCount; 
        selsize(2)=1; 
    else 
        selsize(2)=min(selcolumn+selsize(2)-1,h.Handles.tsTable.getTable.getColumnCount)-selcolumn+1; 
    end 
end 
% update selected block parameters
if isequal(h.IOData.SelectedColumns,selcolumn:selcolumn+selsize(2)-1) && ...
   isequal(h.IOData.SelectedRows,selrow:selrow+selsize(1)-1)      
    return
end
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
localUpdateTableDisplay(h)
if ignored==h.IOData.checkLimit
    msgbox(sprintf('The first %d time values are invalid.',...
        h.IOData.checkLimit),'Time Series Tools');
end
