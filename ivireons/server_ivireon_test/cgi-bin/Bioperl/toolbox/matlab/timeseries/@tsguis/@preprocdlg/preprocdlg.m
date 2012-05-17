function h = preprocdlg(varargin)

%   Copyright 2004-2005 The MathWorks, Inc.
%   % Revision % % Date %
%% Show the (singleton) preproc dialog

mlock
persistent dlg;

if nargin==0
    if isempty(dlg) || ~ishandle(dlg)
        h = tsguis.preprocdlg;
    else
        h = dlg;       
    end
    return
else
    hostnode = varargin{1};
end

%% If necessary build the merge dialog
if isempty(dlg) || ~ishandle(dlg)
    dlg = tsguis.preprocdlg;
    
    % Create the figure and label
    dlg.Figure = figure('Units','Characters','Position',[50 19 90 37],'Toolbar',...
       'None','Numbertitle','off','Menubar','None','Name','Process Data',...
       'Visible','off','closeRequestFcn',@(es,ed) set(dlg,'Visible','off'),...
       'IntegerHandle','off','Resize','off');
    dlg.Handles.LBLselts = uicontrol('Style','Text','Parent',dlg.Figure,'Units','Characters','Position',...
       [3 34 16 1.154],'String','Select view:','HorizontalAlignment',...
       'Left');
    % Plots/views are listed in a combo to indicate that the target of
    % this singleton can be changed
    dlg.Handles.COMBOselectView = uicontrol('Style','Popupmenu','Parent', ...
       dlg.Figure,'Units','Characters','Position',[20.6 33.769 60 1.6920],...
       'String',{''},'Callback',{@localSwitchView dlg});
    if ~ismac
        set(dlg.Handles.COMBOselectView,'BackgroundColor',[1 1 1]);
    end

    % The viewnode must be set for the viewnode grandparent to be set
    if isa(hostnode,'tsguis.viewnode')
        dlg.ViewNode = hostnode;
    else % Opened from a plot
        dlg.ViewNode = hostnode.Parent;
    end
    dlg.initialize
    centerfig(dlg.Figure,0);
else
    if isa(hostnode,'tsguis.viewnode')
        dlg.ViewNode = hostnode;
    else % Opened from a plot
        dlg.ViewNode = hostnode.Parent;
    end
end

%% Set the dialog visible
dlg.Visible = 'on';
figure(dlg.Figure);

%% Return the handle
h = dlg;

function localSwitchView(eventSrc, eventData, h)

%% View combo callback which changes the viewNode
ind = get(eventSrc,'Value');
views = get(eventSrc,'Userdata');
h.ViewNode = views(ind);
