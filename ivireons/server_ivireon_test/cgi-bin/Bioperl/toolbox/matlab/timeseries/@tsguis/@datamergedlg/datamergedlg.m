function h = datamergedlg(varargin)

%   Copyright 2006 The MathWorks, Inc.
%   % Revision % % Date %
%% Show the (singleton) preproc dialog

mlock
persistent dlg;

if nargin==0
    if isempty(dlg) || ~ishandle(dlg)
        h = tsguis.datamergedlg;
    else
        h = dlg;       
    end
    return
else
    hostnode = varargin{1};
end

%% If necessary build the merge dialog
if isempty(dlg) || ~ishandle(dlg)
    dlg = tsguis.datamergedlg;

    % datapreprocdlg specific controls
    dlg.Figure = figure('Units','Characters','Position',...
       [104 21.7627 85.4 39.7573],'Toolbar',...
      'None','Numbertitle','off','Menubar','None','Name','Resample Data',...
      'Visible','off','closeRequestFcn',@(es,ed) set(dlg,'Visible','off'),...
      'IntegerHandle','off','Resize','off','HandleVisibility','Callback');
    dlg.Handles.LBLselts = uicontrol('Style','Text','Parent',dlg.Figure,'Units','Characters','Position',...
       [2 37.5 60 1.154],'String','Selected Node:','HorizontalAlignment',...
       'Left');
    dlg.Handles.LBLTsHost = uicontrol('Style','Text','Parent', ...
       dlg.Figure,'Units','Characters','Position',[20 37.5 60 1.154],...
       'HorizontalAlignment','Left');

    % The host node
    dlg.ViewNode = hostnode;
    
    % Build the dialog
    dlg.initialize
    centerfig(dlg.Figure,0);

else
    dlg.ViewNode = hostnode;
end

%% Refresh the host label
if strcmp(dlg.ViewNode.Label,'default')
    set(dlg.Handles.LBLTsHost,'String','default ')
else
    set(dlg.Handles.LBLTsHost,'String',dlg.ViewNode.Label)
end

%% Refresh the timeseries table
dlg.update;

%% The datapreprocdlg must be modal
set(dlg.Figure,'Windowstyle','modal') 

%% Set the dialog visible
dlg.Visible = 'on';

%% Return the handle
h = dlg;

uiwait(dlg.Figure);