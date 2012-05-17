function flag=initializeDataPanel(h, FileName)
% INITIALIZEDATAPANEL initializes the 'Select Data to Import' panel, which
% contains either an activex control or a uitable for spreadsheet display,
% as well as a few other uicontrols

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2008/12/29 02:11:05 $

import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.widgets.spreadsheet.*;
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
h.DefaultPos.DataPanelDefaultColor = h.DefaultPos.FigureDefaultColor;
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


% Populate the table using the data from the import file
flag = h.ReadCSVFile(FileName);
if ~flag
    return
end

% Build the table panel
[h.Handles.tsTableComponent,h.Handles.tsTablePanel] = ...
    javacomponent(SpreadsheetScrollPane(h.Handles.tsTable),[0 0 1 1],h.Figure);
set(h.Handles.tsTablePanel,'Units','Pixels','Position', ...
    [0 0 1 1], ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor);

% Use the file name as the default time series object name
[junk,thisFileName] = fileparts(FileName); 
set(h.Parent.Handles.EDTsingleNEW,'String',genvarname(thisFileName));

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
        updateTableDisp(h);
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
        updateTableDisp(h);
    end
    msgbox(xlate('Use standard Excel cell indexing format, e.g. A12'),'Time Series Tools');
    return
end
% get block size and check if it is a valid block    

tmpSheet = h.IOData.rawdata;
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
        if ~isempty(ignored) && ignored>0
            if sellast_column==selfirst_column
                if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                    set(eventSrc,'String','');
                else
                    if strcmp(token,'FROM')
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                    else
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                    end
                    updateTableDisp(h);
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
        ignored = h.IgnoreFirstColumnRow;
        if ~isempty(ignored) && ignored>0
            if sellast_row==selfirst_row
                if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                    set(eventSrc,'String','');
                else
                    if strcmp(token,'FROM')
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                    else
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                    end
                    updateTableDisp(h);
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
updateTableDisp(h);

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

