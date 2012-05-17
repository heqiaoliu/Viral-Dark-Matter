function TimePanelUpdate(h,option)
% TIMEPANELUPDATE updates the controls in time panel to the current display

% Author: Rong Chen 
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2005/07/14 15:24:48 $

if strcmp(option,'column')
    % populate the index combo
    huicTXTtimeIndex = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeIndex,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_time_column_mat'',''modal'')')
    set(h.Handles.TXTtimeIndex,'String',xlate('Time is in column : '),'UIContextMenu',huicTXTtimeIndex);
    set(h.Handles.COMBtimeIndex,'String',h.GetColumn,'Value',1);
    % populate the unit/format combo
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
else
    huicTXTtimeIndex = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeIndex,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_time_row_mat'',''modal'')')
    set(h.Handles.TXTtimeIndex,'String',xlate('Time is in row : '),'UIContextMenu',huicTXTtimeIndex);
    set(h.Handles.COMBtimeIndex,'String',h.GetRow,'Value',1);
    % populate the unit/format combo
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
end