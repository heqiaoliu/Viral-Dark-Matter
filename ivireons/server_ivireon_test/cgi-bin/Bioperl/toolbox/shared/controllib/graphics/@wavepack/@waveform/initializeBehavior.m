function initializeBehavior(this)
%initializeBehavior  Initializes the behavior for plot edit and propertyeditor
%   for the @waveform instance.

%  Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2009/12/22 18:57:45 $

% Initialize HGGroup for each axes
Group = this.Group(:);
this.DoUpdateName = true;
for ct = 1:numel(Group)
    LocalAddScribeMenuProp(Group(ct))
end

% Add listeners for displayname changes
localAddNameListener(this);

% Create linking for selected
localLinkSelected(this);
    
if numel(Group) > 0
    % Plot Tools Behavior
    bh = hgbehaviorfactory('PlotTools');
    bh.PropEditPanelObject = this;
    bh.PropEditPanelJavaClass= 'com.mathworks.toolbox.shared.controllib.propertyeditors.WaveformPropertyPanel';
    hgaddbehavior(Group,bh);
    
    % Plot Edit Behavior
    bh = hgbehaviorfactory('PlotEdit');
    bh.EnableCopy = false;
    bh.EnablePaste = false;
    bh.EnableDelete = false;
    hgaddbehavior(Group,bh);
end

end


function localAddNameListener(this)
% Set up listener to display name changes
this.NameListener.deleteListeners;
Group = handle(this.Group);

if numel(Group)>0
    Group = handle(Group);
    L = controllibutils.ListenerManager.createVectListeners(Group, ...
        'DisplayName','PostSet',@(es,ed) LocalSetName(es,ed,this));
    this.NameListener.addListeners(L);
end

end

function LocalSetName(es,ed,this)
% Change Name
% Using a variable is to bypass listeners is more efficient then disabling
% them and re-enabling them
if this.DoUpdateName
    this.Name = get(ed.AffectedObject,'DisplayName');
end
end


%%
function LocalAddScribeMenuProp(Group)
% Set up custom plot edit menu
Group = handle(Group);

if isobject(Group)
    if isprop(Group,'ScribeContextMenu')
        p = Group.findprop('ScribeContextMenu');
    else
        p = addprop(Group,'ScribeContextMenu');
    end
    p.GetMethod = @LocalGetScribeContextMenu;
else
    if isprop(Group,'ScribeContextMenu')
        p = Group.findprop('ScribeContextMenu');
    else
        p=schema.prop(Group,'ScribeContextMenu','MATLAB array');
    end
    p.getfunction = {@LocalGetScribeContextMenu};
end
end


%%
function hmenu = LocalGetScribeContextMenu(Group, varargin)
% Create custom plot edit mode menu
hFig = ancestor(Group,'figure');
hmenu = [];
        
% Only create menu in plot edit mode
if isactiveuimode(hFig,'Standard.EditPlot')
    % Determine if other objects are selected
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
    for ct = 1:length(hObj)
        hB = hggetbehavior(hObj(ct),'PlotTools','-peek');
        if ~isempty(hB) && ~isempty(hB.PropEditPanelObject)
            Targets(ct) = hB.PropEditPanelObject;
        else
            Targets = [];
            break
        end
    end
else
    return
end

if isempty(Targets)
    return;
else
    % Make sure list of targets are unique
    Targets = unique(Targets);
end


% Create Delete Menu Item
% RE: Need to be careful about @plot vs @respplot
% hmenu(end+1) = uimenu(hFig,...
%     'HandleVisibility','off',...
%     'Label','Delete',...
%     'Separator','off',...
%     'Visible','off',...
%     'Callback',@(es,ed) rmresponse(this.Parent,Targets));

% Create Line Color Menu Item
hmenu(end+1) = uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',ctrlMsgUtils.message('Controllib:plots:strColorddd'),...
    'Visible','off',...
    'Separator','on',...
    'Tag', 'Color', ...
    'Callback',@(es,ed) LocalSetColor(Targets));

% Create Line Style Menu Item
descriptions = {'solid','dash','dot','dash-dot','none'};
LineStyleLabels = {...
    ctrlMsgUtils.message('Controllib:plots:strLineStyleSolid'), ...
    ctrlMsgUtils.message('Controllib:plots:strLineStyleDash'), ...
    ctrlMsgUtils.message('Controllib:plots:strLineStyleDot'), ...
    ctrlMsgUtils.message('Controllib:plots:strLineStyleDashDot'), ...
    ctrlMsgUtils.message('Controllib:plots:strnone')};
    
values = {'-','--',':','-.','none'};

hmenu(end+1)=uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',ctrlMsgUtils.message('Controllib:plots:strLineStyle'),...
    'Tag', 'Line Style',...
    'Visible','off');
for k=1:length(values)
    uimenu(hmenu(end),...
        'HandleVisibility','off',...
        'Label',LineStyleLabels{k},...
        'Separator','off',...
        'Visible','off',...
        'Tag',descriptions{k},...
        'Callback',@(es,ed) LocalSetStyle(Targets,'LineStyle',values{k}));
end


% Create Line Width Menu Item
values = [.5,1:1:12];
format = '%1.1f';
hmenu(end+1)=uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',ctrlMsgUtils.message('Controllib:plots:strLineWidth'),...
    'Tag', 'Line Width', ...
    'Visible','off');
for k=1:length(values)
    uimenu(hmenu(end),...
        'HandleVisibility','off',...
        'Label',sprintf(format,values(k)),...
        'Separator','off',...
        'Visible','off',...
        'Callback',@(es,ed) LocalSetStyle(Targets,'LineWidth',values(k)));
end


% Create Marker Style Menu Item
descriptions = {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'};
MarkerStyleLabels = {...
    '+','o','*','.','x', ...
    ctrlMsgUtils.message('Controllib:plots:strMarkerStyleSquare'), ...
    ctrlMsgUtils.message('Controllib:plots:strMarkerStyleDiamond'), ...
    'v','^','>','<', ...
    ctrlMsgUtils.message('Controllib:plots:strMarkerStylePentagram'), ...
    ctrlMsgUtils.message('Controllib:plots:strMarkerStyleHexagram'), ...
    ctrlMsgUtils.message('Controllib:plots:strnone')};

values = {'+','o','*','.','x','s','d','v','^','>','<','p','h','none'};

hmenu(end+1)=uimenu(hFig,...
    'HandleVisibility','off',...
    'Label',ctrlMsgUtils.message('Controllib:plots:strMarker'),...
    'Tag', 'Marker', ...
    'Visible','off');
for k=1:length(values)
    uimenu(hmenu(end),...
        'HandleVisibility','off',...
        'Label',MarkerStyleLabels{k},...
        'Separator','off',...
        'Visible','off',...
        'Tag', descriptions{k}, ...
        'Callback',@(es,ed) LocalSetStyle(Targets,'Marker',values{k}));
end

set(hmenu,'Parent',hMode.UIContextMenu)

end



%% Color callback. Launches color picker.
function LocalSetColor(Targets)

c = uisetcolor();
if ~isequal(c,0)
    LocalSetStyle(Targets,'Color',c)
end
end


%% Set style of targets
function LocalSetStyle(Targets,Prop,Value)

for ct = 1:length(Targets)
    setstyle(Targets(ct),Prop,Value)
end

end

%% Link selected
function localLinkSelected(this)
% Set up listener to selected property changes
% This links the selected behavior of all the groups
this.SelectedListener.deleteListeners;
Group = handle(this.Group);
if ~isempty(Group)
    Group = handle(Group);
    L = controllibutils.ListenerManager.createVectListeners(Group, ...
        'Selected','PostSet',@(es,ed) localUpdateSelected(es,ed,this));
    this.SelectedListener.addListeners(L);
end

end



function localUpdateSelected(es,ed,this)
Group = handle(this.Group);
if ~isempty(Group)
    this.SelectedListener.setEnabled(false)
    set(Group,'Selected',get(ed.AffectedObject,'Selected'))
    this.SelectedListener.setEnabled(true)
end

end
