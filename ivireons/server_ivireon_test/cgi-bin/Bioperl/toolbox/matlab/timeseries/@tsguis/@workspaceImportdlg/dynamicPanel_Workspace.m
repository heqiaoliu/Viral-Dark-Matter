function dynamicPanel_Workspace(h)
% DYNAMICPANEL_WORKSPACE initializes dynamic panel

% Author: Rong Chen 
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2006/10/10 02:27:10 $

h.Handles.PNLtimeWorkspace = uipanel('Parent',h.Handles.PNLtime,...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'BorderType','none',...
    'Position',[5 ...
                5 ...
                h.DefaultPos.widthpnl-10 ...
                h.DefaultPos.TXTtimeSheetbottomoffset-h.DefaultPos.separation-5], ...
    'Visible','off' ...                
    );

% create sheet combobox controls whose values are based on the rawdata
huicBTNSelectVariable = uicontextmenu('Parent',h.Figure);
h.Handles.BTNSelectVariable = uicontrol('Parent',h.Handles.PNLtimeWorkspace, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',xlate('Select Variable...'),...
    'UIContextMenu',huicBTNSelectVariable,...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset ...
                h.DefaultPos.TXTtimeIndexwidth ...
                h.DefaultPos.heightbtn],...
    'Callback',{@localButton h} ...
    );
uimenu(huicBTNSelectVariable,'Label','What''s This','Callback','tsDispatchHelp(''its_wiz_select_variable_button'',''modal'')')

h.Handles.TXTtimeWorkspaceFormat = uicontrol('Parent',h.Handles.PNLtimeWorkspace,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'HorizontalAlignment','Left', ...
    'String',xlate('Units : '), ...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset-32 ...
                40 ...
                h.DefaultPos.heighttxt] ...
    );
h.Handles.COMBtimeWorkspaceFormat = uicontrol('Parent',h.Handles.PNLtimeWorkspace,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',{'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'}, ...
    'Value',5, ...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset+50 ...
                h.DefaultPos.TXTtimeIndexbottomoffset-28 ...
                h.DefaultPos.TXTtimeIndexwidth-50 ...
                h.DefaultPos.heightcomb] ...
    );
if ~ismac
   set(h.Handles.COMBtimeWorkspaceFormat,'BackgroundColor',[1 1 1]);
end

h.Handles.PNLDisplayWorkspaceInfo = uipanel('Parent',h.Handles.PNLtimeWorkspace,...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'Title',xlate(' Selected Time Vector '),...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation ...
                5 ...
                h.DefaultPos.widthpnl-10-h.DefaultPos.separation-(h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation) ...
                60] ...
    );
h.Handles.TXTDisplayWorkspaceInfo = uicontrol('Parent',h.Handles.PNLDisplayWorkspaceInfo,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'String','',...
    'HorizontalAlignment','Left',...
    'Position',[5 ...
                5 ...
                h.DefaultPos.widthpnl-10-h.DefaultPos.separation-(h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation)-10 ...
                60-20] ...
    );


function localButton(eventSrc, eventData, h)
%% Callback for the absolute/relative time format combo

tmp=tsguis.timeFromWorkspaceDlg([]);
tmp.Parent=h;
tmp.open;
h.IOData.timeFromWorkspace=tmp.OutputValue;
h.IOData.timeFormatFromWorkspace=tmp.OutputValueFormat;
if h.IOData.timeFormatFromWorkspace>=0
    set(h.Handles.COMBtimeWorkspaceFormat,'Visible','off');    
    set(h.Handles.TXTtimeWorkspaceFormat,'Visible','off');   
else
    set(h.Handles.COMBtimeWorkspaceFormat,'Visible','on');    
    set(h.Handles.TXTtimeWorkspaceFormat,'Visible','on');   
end
% display the selection
set(h.Handles.TXTDisplayWorkspaceInfo,'String',tmp.OutputString);