function build(this)
%BUILD  Builds dialog.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/12/04 22:21:55 $

import java.awt.*;

ConfigData = this.ConfigData;
Config = ConfigData.Configuration;

% Parameters
Color = get(0,'DefaultUIControlBackground'); %[0.8 0.8 0.8];

% Figure size
Units = get(0,'Units');
set(0,'Units','pixel');
FigSize = get(0,'DefaultFigurePosition');
FigSize(4) = 0.9*FigSize(4);
set(0,'Units',Units);

% Create figure
hfig = figure('Color',Color, ...
   'Name',xlate('Control Architecture'),...
   'MenuBar','none', ...%   'Resize','off', ...
   'Units','pixel', ...
   'Position',FigSize, ...
   'IntegerHandle','off', ...
   'HandleVisibility','callback',...
   'NumberTitle','off', ...%   'WindowStyle','modal',...
   'Visible','off', ...
   'CloseRequestFcn', {@LocalHide this});
this.Figure = handle(hfig);

FigPos = get(hfig,'position');

%%
SelectionPanel= uipanel('Parent', hfig, 'units','normalized','position',[0,.1,0.2,0.85],...
    'Title',xlate('Select Control Architecture:'), 'BorderType','none');

DisplayPanel= uipanel('Parent', hfig, 'units','normalized','position',[0.225,.1,.75,.85],...
    'BorderType','none');


%% Build List Box Selector for architecture

% Create vector of labels for list selection elements
v=java.util.Vector;
numConfig = 6;
for ct = 1:numConfig
    ListLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',...
        javaObjectEDT('javax.swing.ImageIcon',sisogui.getIconPath(ct,'thumbnail')));
    v.addElement(ListLabel);
end

% List selection for configurations
ConfigList = javaObjectEDT('com.mathworks.mwswing.MJList',v);
ConfigList.setCellRenderer(javaObjectEDT('com.mathworks.toolbox.control.sisogui.CustomListItem'));
ConfigList.setSelectedIndex(Config-1);
ConfigList.setName('ConfigSelection');
this.ListSelection = ConfigList;

% Scroll Pan
SP = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',ConfigList);

[ListCOMPONENT, ListCONTAINER] = javacomponent(SP,[.1,.1,.9,.9],SelectionPanel);
set(ListCONTAINER,'units','normalized')
set(ListCONTAINER,'position',[0.05,0,.95,.98])



h = handle(ConfigList, 'callbackproperties' );
hListener = handle.listener(h, 'ValueChanged',{@LocalSelectConfig, this});

this.Listeners = [this.Listeners;hListener];


%% Build Display Panel
% Labels and signs
set(DisplayPanel,'units','Normalized');
PanelPos = get(DisplayPanel,'Position');

DiagramPanel = uipanel('parent',DisplayPanel, ...
    'position',[0, 0.4, 1, 0.6],'bordertype','none');


A = axes('Parent',DiagramPanel, ...
    'Units','normalized', ...
    'Position',[0 0 1 1],...
    'visible','off',...
    'Color',Color, ...
    'XColor',Color, ...
    'YColor',Color, ...
    'ZColor',Color,...
    'Ylim',[0 1],...
    'Xlim',[0 1]);

this.DiagramAxes = A;

Diagram = loopstruct(A, ConfigData, 'labels', []);
set(DisplayPanel,'units','pixels')
PanelPos = get(DisplayPanel,'Position');
set(DisplayPanel,'units','Normalized')

%% Create the tab pane
TabbedPane = javaObjectEDT('com.mathworks.mwswing.MJTabbedPane',1);

%% SIGNS TAB
SignsTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
TabbedPane.addTab(sprintf('Signs'), SignsTab);

for ct = 1:length(ConfigData.FeedbackSign)
    if isequal(ConfigData.FeedbackSign(ct),1)
        FeedbackStr = '+1';
    else
        FeedbackStr = '-1';
    end
    FeedbackSignData(ct,:) = {['S',num2str(ct)],FeedbackStr};
end

% Create the sign selection table
SignTablePanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.SignTablePanel');
SignTableModel = SignTablePanel.getSignTableModel;
SignTableModel.setData(FeedbackSignData);
SignsTab.add(SignTablePanel);

% Set the table changed listener
h = handle(SignTableModel, 'callbackproperties' );
hListener = handle.listener(h, ...
    'tableChanged',{@LocalUpdateFeedbackSign, this});

this.Listeners = [this.Listeners;hListener];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BlocksAndSignalTab = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, 10));
TabbedPane.addTab(sprintf('Blocks and Signals'), BlocksAndSignalTab);

BlocksAndSignalData = LocalGetBlocksAndSignalsData(this);

BlocksAndSignalLabelPanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.BlocksAndSignalLabelPanel');
BlocksAndSignalsTableModel = BlocksAndSignalLabelPanel.getBlocksAndSignalTableModel;
util = slcontrol.Utilities;
BlocksAndSignalsTableModel.setData(matlab2java(util,BlocksAndSignalData));
BlocksAndSignalTab.add(BlocksAndSignalLabelPanel);

h = handle(BlocksAndSignalsTableModel, 'callbackproperties' );
hListener = handle.listener(h, ...
    'tableChanged',{@LocalUpdateLabel, this});

this.Listeners = [this.Listeners;hListener];

this.TableModels.BlocksAndSignalsTableModel=BlocksAndSignalsTableModel;
this.TableModels.SignTableModel=SignTableModel;


%%
% TunedLoopsTab = MJPanel(BorderLayout(0, 10));
% TabbedPane.addTab('Loops', TunedLoopsTab);
%
% for ct = 1:length(ConfigData.Tuned)
%     LoopsData(ct,:) = {ConfigData.Loops{ct}, ConfigData.(ConfigData.Loops{ct}).Name,...
%         ConfigData.(ConfigData.Loops{ct}).Description};
% end
%
% LoopsTable = MJTable( LoopsData,{'Identifier','Name','Description'});
% LoopsTableScrollPane = MJScrollPane(LoopsTable);
%
% TunedLoopsTab.add(LoopsTableScrollPane);
%
% h = handle(SignTableModel, 'callbackproperties' );
% hListener = handle.listener(h, ...
%     'tableChanged',{@LocalUpdateFeedbackSign, this});

this.Listeners = [this.Listeners;hListener];

[HCOMPONENT, HCONTAINER] = javacomponent(TabbedPane,[0.05,0.05,PanelPos(3),PanelPos(4)*.4],DisplayPanel);
set(HCONTAINER,'units','Normalized')
set(HCONTAINER,'position',[0,0,1,.4])



%%

xgap = 0.015*FigSize(3);
tgap = 0.015*FigSize(4);
bgap = 0.07*FigSize(4);
% OK/Cancel/Help buttons
bygap = 3;
bxgap = 3;
bh = bgap-2*bygap;
bw = 60;
bx = FigSize(3)-3*bw-2*bxgap-xgap;
uicontrol('Parent',hfig, ...
   'Units','pixel', ...
   'Position',[bx bygap bw bh], ...
   'Callback',{@LocalApply this}, ...
   'String','OK');
uicontrol('Parent',hfig, ...
   'Units','pixel', ...
   'Position',[bx+bw+bxgap bygap bw bh], ...
   'Callback',{@LocalHide this}, ...
   'String','Cancel');
uicontrol('Parent',hfig, ...
   'Units','pixel', ...
   'Position',[bx+2*(bw+bxgap) bygap bw bh], ...
   'Callback',{@LocalHelp}, ...
   'String','Help');

% Listener to figure visibility to sync up
this.Listeners = [this.Listeners;...
      handle.listener(this.Figure,this.Figure.findprop('Visible'),'PropertyPreSet',{@LocalSyncUp this});
      handle.listener(this.Parent,'ObjectBeingDestroyed',{@LocalDestroy this})];


%--------------- Callback functions -----------------------------
%%
function LocalDestroy(eventsrc,eventdata,this)
% delete figure
delete(this.Figure)

%%
function LocalHelp(eventsrc,eventdata)
mapfile = ctrlguihelp;
helpview(mapfile,'siso_ControlArchitecture','CSHelpWindow');

%%
function LocalSyncUp(eventsrc,eventdata,this)
% Syncs up dialog contents when figure becomes visible
if strcmp(eventdata.NewValue,'on')
   % Sync up internal data structure
   sync(this)
   % Build/show selected tab
   this.refreshpanel;
end
   
%%
function LocalHide(eventsrc,eventdata,this)
% Hides window
this.Figure.Visible = 'off';

%%
function LocalApply(eventsrc,eventdata,this)
% Callback for OK button
ConfigData = this.ConfigData;

% Apply configuration settings
this.Parent.configapply(ConfigData)
delete(this.Figure);


%%
function Data = LocalGetBlocksAndSignalsData(this)
% Create Data for Table
ConfigData = this.ConfigData;
DefaultDesign = sisoinit(ConfigData.Configuration);

Tuned = ConfigData.Tuned;
Fixed = ConfigData.Fixed;
Blocks = [ConfigData.Tuned(:);ConfigData.Fixed(:)];

IDList =  [Blocks; DefaultDesign.Input(:); DefaultDesign.Output(:)];

for ct = 1:length(Blocks)
    Data{ct,1} = ConfigData.(Blocks{ct}).Name;
end

Data = [Data; ConfigData.Input(:); ConfigData.Output(:)];

Data = [IDList,Data];

function LocalUpdateLabel(es,ed,this)
% update labels

idx = ed.JavaEvent.getFirstRow + 1;
% Update only if row is selected
% Tablechanged event can be fired during update
if ~isequal(idx,0) && ed.JavaEvent.getColumn ~=-1
    Value = es.getValueAt(ed.JavaEvent.getFirstRow,ed.JavaEvent.getColumn);

    ConfigData = this.ConfigData;

    Blocks = [ConfigData.Tuned(:); ConfigData.Fixed(:)];

    numBlocks = length(Blocks);
    numInputs = length(ConfigData.Input);


    if idx <= length(Blocks)
        ConfigData.(Blocks{idx}).Name = Value;
    else
        if idx <= numBlocks+numInputs
            ConfigData.Input{idx-numBlocks} = Value;
        else
            ConfigData.Output{idx-numBlocks-numInputs} = Value;
        end
    end

    this.ConfigData = ConfigData;
end


%%
function LocalSelectConfig(eventsrc,eventdata,this)
if ~this.ListSelection.getValueIsAdjusting
    % New config is index + 1 (java to matlab indexing)
    NewConfig = this.ListSelection.getSelectedIndex+1;
    % Change configuration
    this.setconfig(NewConfig)
    this.refreshpanel
end

%%
function LocalUpdateFeedbackSign(es,ed,this)
% update feedback signs

idx = ed.JavaEvent.getFirstRow + 1;
% Update only if row is selected
% Tablechanged event can be fired during update
if ~isequal(idx,0) && ed.JavaEvent.getColumn ~=-1
    Value = es.getValueAt(ed.JavaEvent.getFirstRow,ed.JavaEvent.getColumn);
    this.ConfigData.FeedbackSign(idx) = eval(Value);
    this.refreshDiagram;
end