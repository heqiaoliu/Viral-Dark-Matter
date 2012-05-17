function dynamicPanel_CurrentSheet(h)
% DYNAMICPANEL_CURRENTSHEET initializes dynamic panel

% Author: Rong Chen 
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.10 $ $Date: 2006/12/20 07:18:50 $

% create first dynamic panel for 'current sheet' selection

h.Handles.PNLtimeCurrentSheet = uipanel('Parent',h.Handles.PNLtime,...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'BorderType','none',...
    'Position',[5 ...
                5 ...
                h.DefaultPos.widthpnl-10 ...
                h.DefaultPos.TXTtimeSheetbottomoffset-h.DefaultPos.separation-5], ...
    'Visible','on' ...                                
    );

% sheet combobox controls whose values are based on the rawdata
% huicTXTtimeIndex = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeIndex = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset ...
                h.DefaultPos.TXTtimeIndexwidth ...
                h.DefaultPos.heighttxt] ...
    );
% 'UIContextMenu',huicTXTtimeIndex
% uimenu(huicTXTtimeIndex,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_time_column_row_xls'',''modal'')')

h.Handles.COMBtimeIndex = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',' ',...
    'TooltipString',xlate('Select a row/column which contains the time vector.'),...
    'Position',[h.DefaultPos.COMBtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset+4 ...
                h.DefaultPos.COMBtimeIndexwidth ...
                h.DefaultPos.heightcomb], ...
    'Callback',{@localSwitchIndex h} ...
    );
if ~ismac
    set(h.Handles.COMBtimeIndex,'BackgroundColor',[1 1 1]);
end
 
% huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeSheetFormat = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTtimeSheetFormatleftoffset ...
                h.DefaultPos.TXTtimeSheetFormatbottomoffset ...
                h.DefaultPos.TXTtimeSheetFormatwidth ...
                h.DefaultPos.heighttxt] ...
    );
% 'UIContextMenu',huicTXTtimeSheetFormat,...
% uimenu(huicTXTtimeSheetFormat,'Label','What''s This','Callback','tsDispatchHelp(''time_units_format_select'',''modal'')')

h.Handles.COMBtimeSheetFormat = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',' ',...
    'TooltipString',xlate('Select a proper time unit or date format'),...
    'Position',[h.DefaultPos.COMBtimeSheetFormatleftoffset ...
                h.DefaultPos.TXTtimeSheetFormatbottomoffset+4 ...
                h.DefaultPos.COMBtimeSheetFormatwidth ...
                h.DefaultPos.heightcomb] ...
    );
if ~ismac
    set(h.Handles.COMBtimeSheetFormat,'BackgroundColor',[1 1 1]);
end

% start, end
huicTXTtimeSheetStart = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeSheetStart = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'String',xlate('Time :   First value '),...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTtimeSheetStart,...
    'Position',[h.DefaultPos.TXTtimeSheetStartleftoffset ...
                h.DefaultPos.TXTtimeSheetStartbottomoffset ...
                h.DefaultPos.TXTtimeSheetStartwidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTtimeSheetStart,'Label','What''s This','Callback','tsDispatchHelp(''time_first'',''modal'')')

h.Handles.EDTtimeSheetStart = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','edit', ...
    'Units','Pixels',...
    'BackgroundColor',[1 1 1],...
    'String',' ',...
    'TooltipString',xlate('Put in the starting point of the time range in a proper format, and the import wizard will automatically locate the valid time points with the user-defined range.'),...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.EDTtimeSheetStartleftoffset ...
                h.DefaultPos.TXTtimeSheetStartbottomoffset+2 ...
                h.DefaultPos.EDTtimeSheetStartwidth ...
                h.DefaultPos.heightedt], ...
    'Callback',{@localChangeTime h} ...                
    );

huicTXTtimeSheetEnd = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeSheetEnd = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'String',xlate('Last value '),...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTtimeSheetEnd,...
    'Position',[h.DefaultPos.TXTtimeSheetEndleftoffset ...
                h.DefaultPos.TXTtimeSheetEndbottomoffset ...
                h.DefaultPos.TXTtimeSheetEndwidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTtimeSheetEnd,'Label','What''s This','Callback','tsDispatchHelp(''time_last'',''modal'')')

h.Handles.EDTtimeSheetEnd = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','edit', ...
    'Units','Pixels',...
    'BackgroundColor',[1 1 1],...
    'String',' ',...
    'TooltipString',xlate('Put in the ending point of the time range in a proper format, and the import wizard will automatically locate the valid time points with the user-defined range.'),...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.EDTtimeSheetEndleftoffset ...
                h.DefaultPos.TXTtimeSheetEndbottomoffset+2 ...
                h.DefaultPos.EDTtimeSheetEndwidth ...
                h.DefaultPos.heightedt], ...
    'Callback',{@localChangeTime h} ...                                
    );


% -------------------------------------------------------------------------
%% current sheet dynamic panel callbacks
% -------------------------------------------------------------------------
function localChangeTime(eventSrc, eventData, h)
% callback of edit boxes

% get first row
first=strtrim(get(h.Handles.EDTtimeSheetStart,'String'));
% get last row
last=strtrim(get(h.Handles.EDTtimeSheetEnd,'String'));
% get time range
if ~isempty(first) && ~isempty(last)
    timeindex=h.getTimeVectorRange(first,last);
else
    return
end
if isempty(timeindex)
    % due to the drawnow issue in the errordlg function, we have to set
    % the callback functions of the two editboxes to [] first and then
    % set them back to normal status after the errordlg is called 
    set(h.Handles.EDTtimeSheetStart,'Callback',[]);
    set(h.Handles.EDTtimeSheetEnd,'Callback',[]);
    % if previous valid selection exists, restore it
    if get(h.Handles.COMBdataSample,'Value')==1
        if ~isempty(h.IOData.SelectedRows)
            updateStartEndTime(h,h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
        else
            set(h.Handles.EDTtimeSheetStart,'String','');
            set(h.Handles.EDTtimeSheetEnd,'String','');
        end
    else
        if ~isempty(h.IOData.SelectedColumns)
            updateStartEndTime(h,h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
        else
            set(h.Handles.EDTtimeSheetStart,'String','');
            set(h.Handles.EDTtimeSheetEnd,'String','');
        end
    end
    errordlg('Invalid time range.','Time Series Tools','modal');
    % 
    set(h.Handles.EDTtimeSheetStart,'Callback',{@localChangeTime h});
    set(h.Handles.EDTtimeSheetEnd,'Callback',{@localChangeTime h});
else
    if get(h.Handles.COMBdataSample,'Value')==1
        h.IOData.SelectedRows=(timeindex(1):timeindex(end))';
    else
        h.IOData.SelectedColumns=(timeindex(1):timeindex(end))';
    end
    % update displays in the editboxes
    set(h.Handles.EDTFROM,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
    set(h.Handles.EDTTO,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
    % update table selection
    updateTableDisp(h);
end


function localSwitchIndex(eventSrc, eventData, h)
if get(h.Handles.COMBdataSample,'Value')==1
    % a sample is a row (time vector is a column)
    localSwitchColumn(h);
else
    % a sample is a column (time vector is a row)
    localSwitchRow(h);
end


function localSwitchColumn(h)
% callback for the column combobox in the time panel
% check if a valid time vector exists
columnLength = h.getDataSize(2);
if get(h.Handles.COMBtimeIndex,'Value')==h.IOData.checkLimitColumn+1
    % if user selects the 'More ...' option, generate a modal window to
    % let user put in column letter
    numlines=1;
    answer=inputdlg(xlate('Enter the column name which stores the time vector: (e.g. AB)         '),'Time Series Tools',numlines);
    if isempty(answer)
        % user select 'cancel', jump back to first
        set(h.Handles.COMBtimeIndex,'Value',1);
    else
        % check if it a valid column name
        columnIndex=h.findcolumnnumber(cell2mat(answer));
        if isempty(columnIndex) || columnIndex>columnLength || columnIndex<1
            % wrong name or column name is invalid
            set(h.Handles.COMBtimeIndex,'Value',1);
        else
            strCell=get(h.Handles.COMBtimeIndex,'String');
            findindex=strfind(strCell,cell2mat(answer));
            if sum(cell2mat(findindex))>0
                % already exist in the combo
                set(h.Handles.COMBtimeIndex,'Value',find(not(cellfun('isempty',findindex))));
            else
                % new selection
                % insert the column name into the combobox
                strCell=[strCell(1:h.IOData.checkLimitColumn);answer;strCell(h.IOData.checkLimitColumn+1)];
                set(h.Handles.COMBtimeIndex,'String',strCell);
                % make it current selection
                set(h.Handles.COMBtimeIndex,'Value',h.IOData.checkLimitColumn+1);
                % change the checklimit
                h.IOData.checkLimitColumn=h.IOData.checkLimitColumn+1;
            end
        end
    end
end
% check if the column contains absolute date/time format
if isfield(h.Handles,'ActiveX') && ~isempty(h.Handles.ActiveX)
    tmpColStr=get(h.Handles.COMBtimeIndex,'String');
    tmpLetter=tmpColStr{get(h.Handles.COMBtimeIndex,'Value')};
    h.checkTimeFormat(h.Handles.ActiveX.ActiveSheet.Name,'column',tmpLetter);
    if h.IOData.formatcell.columnIsAbsTime>=0
        rangeStr=strcat(tmpLetter,'1:',tmpLetter,num2str(h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,1)));
        h.Handles.ActiveX.ActiveSheet.Range(rangeStr).NumberFormat=cell2mat(h.IOData.formatcell.columnFormat);
    end
end
% display
if isfield(h.IOData.formatcell,'columnIsAbsTime') && h.IOData.formatcell.columnIsAbsTime>=0
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeSheetFormat,'Label','What''s This','Callback','tsDispatchHelp(''time_display_format'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',xlate('Format : '),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',h.IOData.formatcell.matlabFormatString);    
    set(h.Handles.COMBtimeSheetFormat,'Value',find(h.IOData.formatcell.matlabFormatIndex == h.IOData.formatcell.columnIsAbsTime));
else
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeSheetFormat,'Label','What''s This','Callback','tsDispatchHelp(''time_units_select'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',xlate('Units : '),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',{'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});    
    set(h.Handles.COMBtimeSheetFormat,'Value',5);
end
if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    else
        % time vector is stored as a row
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    end
end



function localSwitchRow(h)
% callback for the row combobox in the time panel

rowLength = h.getDataSize(1);
if get(h.Handles.COMBtimeIndex,'Value')==h.IOData.checkLimitRow+1
    % if user selects the 'More ...' option, generate a modal window to
    % let user put in row index
    numlines=1;
    answer=inputdlg(xlate('Enter the row index which stores the time vector: (e.g. 12)        '),'Time Series Tools',numlines);
    if isempty(answer)
        % user select 'cancel', jump back to first
        set(h.Handles.COMBtimeIndex,'Value',1);
    else
        % check if it a valid row index
        rowIndex=str2double(cell2mat(answer));
        if isempty(rowIndex) || rowIndex>rowLength || rowIndex<1
            % wrong index or index is invalid
            set(h.Handles.COMBtimeIndex,'Value',1);
        else
            strCell=get(h.Handles.COMBtimeIndex,'String');
            findindex=strfind(strCell,cell2mat(answer));
            if sum(cell2mat(findindex))>0
                % already exist in the combo
                set(h.Handles.COMBtimeIndex,'Value',find(not(cellfun('isempty',findindex))));
            else
                % new selection
                % insert the row index into the combobox
                strCell=[strCell(1:h.IOData.checkLimitRow);answer;strCell(h.IOData.checkLimitRow+1)];
                set(h.Handles.COMBtimeIndex,'String',strCell);
                % make it current selection
                set(h.Handles.COMBtimeIndex,'Value',h.IOData.checkLimitRow+1);
                % change the checklimit
                h.IOData.checkLimitRow=h.IOData.checkLimitRow+1;
            end
        end
    end
end
% check if the row contains absolute date/time format
if  ~isempty(h.Handles.ActiveX)
    tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
    tmpLetter=tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')};
    h.checkTimeFormat(h.Handles.ActiveX.ActiveSheet.Name,'row',tmpLetter);
    if h.IOData.formatcell.rowIsAbsTime>=0
        rangeStr=strcat('A',tmpLetter,':',h.findcolumnletter(h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,2)),tmpLetter);
        h.Handles.ActiveX.ActiveSheet.Range(rangeStr).NumberFormat=cell2mat(h.IOData.formatcell.rowFormat);
    end
end
% display
if isfield(h.IOData.formatcell,'rowIsAbsTime') && h.IOData.formatcell.rowIsAbsTime>=0
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeSheetFormat,'Label','What''s This','Callback','tsDispatchHelp(''time_display_format'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',xlate('Format : '),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',h.IOData.formatcell.matlabFormatString);    
    set(h.Handles.COMBtimeSheetFormat,'Value',find(h.IOData.formatcell.matlabFormatIndex == h.IOData.formatcell.rowIsAbsTime));
else
    % populate the unit/format combo
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeSheetFormat,'Label','What''s This','Callback','tsDispatchHelp(''time_units_select'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',xlate('Units : '),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',{'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});    
    set(h.Handles.COMBtimeSheetFormat,'Value',5);
end
if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    else
        % time vector is stored as a row
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    end
end
