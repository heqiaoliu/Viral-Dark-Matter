function h = mergedlg(varargin)

%   Copyright 2004-2005 The MathWorks, Inc.
%   % Revision % % Date %
%% Show the (singleton) selection dialog

mlock
persistent dlg;

if nargin==0
    if isempty(dlg) || ~ishandle(dlg)
        h = tsguis.mergedlg;
    else
        h = dlg;       
    end
    return
else
    hostnode = varargin{1};
end

%% If necessary build the merge dialog
if isempty(dlg) || ~ishandle(dlg)
    dlg = tsguis.mergedlg;
    
    % Main figure
    dlg.Figure = figure('Units','Characters','Position',[104 21.7627 85.4 39.7573],'Toolbar','None',...
        'Menubar','None','NumberTitle','off','Name',xlate('Resample Data'),...
        'Visible','off','closeRequestFcn',@(es,ed) set(dlg,'Visible','off'),'HandleVisibility',...
        'callback','IntegerHandle','off','Resize','off');

    % Plots/views are listed in a combo to indicate that the target of
    % this singleton can be changed
    dlg.Handles.COMBOselectView = uicontrol('style','popupmenu','String',{'  '},'Units',...
        'Characters','Parent',dlg.Figure,'Position',[29 37.0658 53 1.6918], ...
        'Callback',{@localSwitchView dlg});
    if ~ismac
        set(dlg.Handles.COMBOselectView,'BackgroundColor',[1 1 1]);
    end
    
    TXTselectView = uicontrol('style','text','String',xlate('Select the plot'),'Units',...
        'Pixels','Parent',dlg.Figure,'Position',[17 486 123 15],'HorizontalAlignment','Left');

    % The viewnode must be set for the viewnode grandparent to be set
    if isa(hostnode,'tsguis.viewnode')
        dlg.ViewNode = hostnode;
    else % Opened from a plot
        dlg.ViewNode = hostnode.Parent;
    end
    
    dlg.initialize
    centerfig(dlg.Figure,0);

else
    % The viewnode must be set for the viewnode grandparent to be set
    if isa(hostnode,'tsguis.viewnode')
        dlg.ViewNode = hostnode;
    else % Opened from a plot
        dlg.ViewNode = hostnode.Parent;
    end
end

%% Set the dialog visible
dlg.Visible = 'on';
set(dlg.Figure,'Pointer','arrow')
if nargin>=2 && strcmp(varargin{2},'modal')
    set(dlg.Figure,'Windowstyle',varargin{2})
end
figure(dlg.Figure);

%% Return the handle
h = dlg;


function localSwitchView(eventSrc, eventData, h)

%% View combo callback which changes the viewNode
ind = get(eventSrc,'Value');
views = get(eventSrc,'Userdata');
h.ViewNode = views(ind);
