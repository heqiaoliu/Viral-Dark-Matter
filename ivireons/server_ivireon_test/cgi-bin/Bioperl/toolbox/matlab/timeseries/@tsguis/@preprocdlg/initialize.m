function initialize(h)

% Copyright 2004-2008 The MathWorks, Inc.

%% Builds the Data Selection GUI

import javax.swing.*; 
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************

% Time series panel
PNLselect = uipanel('Parent',h.Figure,'Units','Characters','Position',...
    [2.4 22.07 85 10.769],'Title',xlate('Select Time Series'));


h.Handles.tsTableModel = tsMatlabCallbackTableModel(cell(0,4),...
             {xlate('Modify (y/n)?'),xlate('Time Series'),xlate('Path'),xlate('Selected Column(s)')},...
             'tsDispatchTableCallback',...
             {'refreshInterpPanel' 1 h});
drawnow
h.Handles.tsTableModel.setNoEditCols([1 2]);        
h.Handles.tsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.tsTableModel);
h.Handles.tsTable.setName('preprocdlg:tstable');
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTable);
[junk,tsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
c = javaObjectEDT('javax.swing.JCheckBox');
javaMethod('setCellEditor',h.Handles.tsTable.getColumnModel.getColumn(0),...
    DefaultCellEditor(c));
javaMethod('setCellRenderer',h.Handles.tsTable.getColumnModel.getColumn(0),...
    tsCheckBoxRenderer);
javaMethod('setPreferredWidth',h.Handles.tsTable.getColumnModel.getColumn(2),...
    150);
javaMethod('setAutoResizeMode',h.Handles.tsTable,JTable.AUTO_RESIZE_OFF);
set(tsTablePanel,'Parent',PNLselect,'Units','Characters','Position',...
    [2.6 1 79 7.154])

% 1st column is HTML
h.ViewNode.getRoot.setHTMTableColumn(h.Handles.tsTable,2);
    
% Close button
BTNcancel = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'Position',[73-15 1 13.8 1.769],'String',xlate('Close'),'Callback', ...
    @(es,ed) set(h,'Visible','off')); %#ok<NASGU>
BTNHelp = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'Position',[73 1 13.8 1.769],'String','Help','Callback', ...
    @(es,ed) tsDispatchHelp('d_process_data_plot','modal',h.Figure)); %#ok<NASGU>

% Main preprocessing tabbed panel
PNLpreproc = uipanel('Parent',h.Figure,'Units','Characters','Position',...
    [2.4 3.769 85 17.5 ],'Title',xlate('Process Data'));
LBLclickapply = uicontrol('Parent',PNLpreproc,'Style','text','Units',...
    'Characters','HorizontalAlignment','Left',...
    'Position',[3 14.2 79 1.5 ],'String',...
    xlate('Click Apply in each tab to process the data')); %#ok<NASGU>
% Work around for uitabgroup bug - need to parent to figure first
h.Handles.TABGRPpreproc = uitabgroup('Parent',h.Figure,'Units','Characters',...
    'Position',[0 0 .1 .1]);
set(h.Handles.TABGRPpreproc,'Parent',PNLpreproc,'Position',[2 0  80 14.5]);


% Build detrending button group
h.Handles.TABdetrend = uitab('Parent',h.Handles.TABGRPpreproc,'Title',...
    xlate('Detrend'),'Units','Characters');
s = get(h.Handles.TABdetrend,'Position');
BTNgrpdetrend = uibuttongroup('Parent',h.Handles.TABdetrend,'Units','Characters','Position',...
    [s(1) s(2)+1 s(3)-1 s(4)-1],'Title','','SelectionChangeFcn',...
    {@localDetrend h});
LBLdetrend = uicontrol('Style','Text','Parent',BTNgrpdetrend,'Units','Characters',...
    'Position',[2 8.577 21 1.154],'HorizontalAlignment','Left','String',...
    xlate('Remove trend type:')); %#ok<NASGU>
h.Handles.RADIOconst = uicontrol('Style','radiobutton','Parent',BTNgrpdetrend,'Units','Characters',...
    'Position',[25 8.577 16.4 1.154],'Value',1,'String',xlate('Constant'));
h.Handles.RADIOlinear = uicontrol('Style','radiobutton','Parent',BTNgrpdetrend,'Units','Characters',...
    'Position',[25 6.577 16.4 1.154],'Value',0,'String',xlate('Linear'));    
h.UndoButtons = [h.UndoButtons;uicontrol('style','Pushbutton','Parent',BTNgrpdetrend,'Units','Characters',...
    'Position',[s(3)-31.6  0.7 13.8 1.7690],'String',xlate('Undo'),'Callback', ...
    {@localUndo h},'Enable','off','BusyAction','Cancel','Interruptible','off')];
BTNapplyDetrend = uicontrol('style','Pushbutton','Parent',BTNgrpdetrend,'Units','Characters',...
    'Position',[s(3)-16.8  0.7 13.8 1.7690],'String',xlate('Apply'),'Callback',...
    {@localApply h 'detrend' h.UndoButtons(end)},'BusyAction','Cancel','Interruptible','off'); %#ok<NASGU>

% Build filter panel
h.Handles.TABfilter = uitab('Parent',h.Handles.TABGRPpreproc,'Title',xlate('Filter'),...
    'Units','Characters');
s = get(h.Handles.TABfilter,'Position');
PNLfilter = uipanel('Parent',h.Handles.TABfilter,'Units','Characters','Position',...
    [s(1) s(2)+1 s(3)-1 s(4)-1],'Title','');
TXTfiltertype = uicontrol('Style','text','Parent',PNLfilter,'Units','Characters',...
    'Position',[2 8.423 10.6 1.154],'HorizontalAlignment','Left',...
    'String',xlate('Filter type')); %#ok<NASGU>
filttypes = {xlate('First order (1/(1+ time constant * s))');...
             xlate('Discrete transfer fcn (B(z^-1)/A(z^-1))');...
             xlate('Ideal pass or stop')};
COMBOfiltertype = uicontrol('Style','popupmenu','Parent',PNLfilter,...
    'Units','Characters',...
    'Position',[17.8 8.192 48 1.692],'String',...
    filttypes,'Callback',...
    {@localSetFlterType h});
if ~ismac
    set(COMBOfiltertype,'BackgroundColor',[1 1 1]);
end


% Build time constant panel
h.Handles.PNLtimeconst = uipanel('Parent',PNLfilter,'Units','Characters','Position',...
    [0 3.058 57.4 4.692],'Bordertype','None');
TXTtimeconst = uicontrol('Style','text','Parent',h.Handles.PNLtimeconst, ...
    'Units','Characters','Position',[2 2.692 14.6 1.154],'String', ...
    xlate('Time constant'),'HorizontalAlignment','Left'); %#ok<NASGU>
EDITtimeconst = uicontrol('Style','edit','Parent',h.Handles.PNLtimeconst, ...
    'Units','Characters','Position',[17.8 2.5 48 1.615],'String','10',...
    'HorizontalAlignment','Left','Callback',...
    {@localParseFilterSpec h 'Timeconst' '10'},'Backgroundcolor',[1 1 1]); %#ok<NASGU>

% Build transfer fcn panel
h.Handles.PNLtransfcn = uipanel('Parent',PNLfilter,'Units','Characters','Position',...
    [0 3.058 57.4 4.692],'Bordertype','None','Visible','off');
TXTAcoeff = uicontrol('Style','text','Parent',h.Handles.PNLtransfcn,'Units','Characters',...
    'Position',[2 2.692 14.6 1.154],'String',xlate('A coefficients'),'HorizontalAlignment','Left'); %#ok<NASGU>
EDITAcoeff = uicontrol('Style','edit','Parent',h.Handles.PNLtransfcn,'Units','Characters',...
    'Position',[17.8 2.385 48 1.615],'HorizontalAlignment','Left','String',...
    '[1 -0.5]','Callback',{@localParseFilterSpec h 'Acoeffs' '[1 -0.5]'},...
    'Backgroundcolor',[1 1 1]); %#ok<NASGU>
TXTBcoeff = uicontrol('Style','text','Parent',h.Handles.PNLtransfcn,'Units', ...
    'Characters','Position',[2 0.538 14.6 1.154],'String',xlate('B coefficients'),...
    'HorizontalAlignment','Left'); %#ok<NASGU>
EDITBcoeff = uicontrol('Style','edit','Parent',h.Handles.PNLtransfcn,'Units',...
    'Characters','Position',[17.8 0.231 48 1.615],'HorizontalAlignment',...
    'Left','String','1','Callback', ...
    {@localParseFilterSpec h 'Bcoeffs' '1'},'Backgroundcolor',[1 1 1]); %#ok<NASGU>

% Build ideal filter panel
passstopstr = {'pass','stop'};
h.Handles.PNLideal = uipanel('Parent',PNLfilter,'Units','Characters','Position',...
    [0 3.058 57.4 4.692],'Bordertype','None','Visible','off');
TXTpassstop = uicontrol('Style','text','Parent',h.Handles.PNLideal,'Units','Characters',...
    'Position',[2 2.692 23.6 1.154],'String',xlate('Specify pass/stop band'),'HorizontalAlignment','Left'); %#ok<NASGU>
COMBpassstop = uicontrol('Style','popupmenu','Parent',h.Handles.PNLideal,'Units','Characters',...
    'Position',[26.8 2.385 39 1.615],'String',passstopstr,'Callback',...
    @(es,ed) set(h,'Band',passstopstr{get(es,'Value')})); 
if ~ismac
    set(COMBpassstop,'BackgroundColor',[1 1 1]);
end
TXTidealRange = uicontrol('Style','text','Parent',h.Handles.PNLideal,'Units','Characters',...
    'Position',[2 0.538 23.6 1.154],'String',xlate('Range'),'HorizontalAlignment','Left'); %#ok<NASGU>
EDITidealRange = uicontrol('Style','edit','Parent',h.Handles.PNLideal,'Units','Characters',...
    'Position',[26.8 0.231 39 1.615],'HorizontalAlignment','Left','String',...
    '[0 0.1]','Callback',{@localParseFilterSpec h 'Range' '[0 0.1]'},...
    'Backgroundcolor',[1 1 1]); %#ok<NASGU>

% Add undo and apply buttons
h.UndoButtons = [h.UndoButtons;uicontrol('style','Pushbutton','Parent',PNLfilter,'Units','Characters',...
    'Position',[s(3)-31.6  0.7 13.8 1.7690],'String',xlate('Undo'),'Callback', ...
    {@localUndo h},'Enable','off','BusyAction','Cancel','Interruptible','off')];
BTNapplyFilter = uicontrol('style','Pushbutton','Parent',PNLfilter,'Units','Characters',...
    'Position',[s(3)-16.8 0.7  13.8 1.769],'String',xlate('Apply'),'Callback',...
    {@localApply h 'filt' h.UndoButtons(end)},'BusyAction','Cancel','Interruptible','off'); %#ok<NASGU>

% Build missing button group. TO DO Implement radio button callbacks
h.Handles.TABmissingdata = uitab('Parent',h.Handles.TABGRPpreproc,'Title',xlate('Interpolate'),...
    'Units','Characters');
s = get(h.Handles.TABmissingdata,'Position');
BTNgrpmissing = uibuttongroup('Parent',h.Handles.TABmissingdata,'Units','Characters','Position',...
    [s(1) s(2)+1 s(3)-1 s(4)-1],'Title','','SelectionChangeFcn',{@localUpdateInterpTs h});
LBLremovetimes = uicontrol('Style','Text','Parent',BTNgrpmissing,'Units','Characters',...
    'Position',[2 8.5 42 1.3080],'String',xlate('Interpolate missing data with data from:'));  %#ok<NASGU>
h.Handles.RADIOthists = uicontrol('Style','radiobutton','Parent',BTNgrpmissing,'Units','Characters',...
    'Position',[4.8 6.5 28.4 1.1540],'String',xlate('This time series'),'Value',1);
h.Handles.RADIOotherts = uicontrol('Style','radiobutton','Parent',BTNgrpmissing,'Units','Characters',...
    'Position',[4.8 4.5 45.2 1.1540],'String',xlate('Time series with equal # of columns '));
h.Handles.COMBotherts = uicontrol('Style','popupmenu','Parent',BTNgrpmissing,'Units','Characters',...
    'Position', [44.2 4.2 31 1.692],'String',{''},'Callback',{@localUpdateInterpTs h});
if ~ismac
    set(h.Handles.COMBotherts,'BackgroundColor',[1 1 1]);
end
h.UndoButtons = [h.UndoButtons;uicontrol('style','Pushbutton','Parent',BTNgrpmissing,'Units','Characters',...
    'Position',[s(3)-31.6 0.7 13.8 1.7690],'String',xlate('Undo'),'Callback', ...
    {@localUndo h},'Enable','off','BusyAction','Cancel','Interruptible','off')];
BTNmissing = uicontrol('style','Pushbutton','Parent',BTNgrpmissing,'Units','Characters',...
    'Position',[s(3)-16.8 .7 13.8 1.769],'String',xlate('Apply'),'Callback',...
    {@localApply h 'interp' h.UndoButtons(end)},'BusyAction','Cancel','Interruptible','off'); %#ok<NASGU>


% Missing Data panel
h.Handles.TABinterp = uitab('Parent',h.Handles.TABGRPpreproc,'Title',...
    xlate('Remove Missing Data'),'Units','Characters');
s = get(h.Handles.TABdetrend,'Position');
PNLinterp = uipanel('Parent',h.Handles.TABinterp,'Units','Characters','Position',...
    [s(1) s(2)+1 s(3)-1 s(4)-1],'Title','');
uicontrol('Style','Text','Parent',PNLinterp,'Units','Characters',...
    'Position',[2 8.5 57 1.154],'HorizontalAlignment','Left','String',...
    xlate('Remove time rows where data is missing any or all cells:'));
h.Handles.COMBremovetimes = uicontrol('Style','popupmenu','Parent',PNLinterp,'Units','Characters',...
    'Position',[60 8.3 10 1.6920],'String',{xlate('All'),xlate('Any')},'callback',...
    {@localAnyAllChange h});
if ~ismac
    set(h.Handles.COMBremovetimes,'BackgroundColor',[1 1 1]);
end
h.UndoButtons = [h.UndoButtons;uicontrol('style','Pushbutton','Parent',PNLinterp,'Units','Characters',...
    'Position',[s(3)-31.6  0.7 13.8 1.7690],'String',xlate('Undo'),'Callback', ...
    {@localUndo h},'Enable','off','BusyAction','Cancel','Interruptible','off')];
BTNinterp = uicontrol('style','Pushbutton','Parent',PNLinterp,'Units','Characters',...
    'Position',[s(3)-16.8 .7 13.8 1.769],'String',xlate('Apply'),'Callback',...
    {@localApply h 'remove' h.UndoButtons(end)},'BusyAction','Cancel','Interruptible','off'); %#ok<NASGU>


% Set the figure background to match the panels
set(h.Figure,'color',get(PNLfilter,'backgroundcolor'))

% Install filtering object listeners
h.addlisteners(handle.listener(h,h.findprop('Filter'), ...
      'PropertyPostSet',{@localFilterTypeChange h h.Handles}));

% Create viewdlg listeners
h.generic_listeners

% Enable/disable interp radio buttons depending on whether 1 or more time
% series are selected.
h.refreshInterpPanel;

% Add a listener to control the Enable status of the UndoButtons based on
% the corresponding Apply transaction being on the top of the recorder
% stack.
r = tsguis.recorder;
h.addlisteners(handle.listener(r,r.findprop('Undo'),'PropertyPostSet',...
    {@localUndoActive h.UndoButtons r}));
for k=1:length(h.UndoButtons)
    set(h.UndoButtons(k),'CallBack',@(es,ed) undo(r))
end

%% Set handlevisibility to 'off'. Must be at the end to work around
%% issue with tabdlg
set(h.Figure,'HandleVisibility','callback');

function localDetrend(eventSrc,eventData,h)

%% Callback for detrend radio buttons which sets the Detrend type prop

set(h.Figure,'Pointer','watch')
if get(h.Handles.RADIOconst,'Value')==1
    h.Detrendtype = 'constant';
else
    h.Detrendtype = 'linear';
end
set(h.Figure,'Pointer','arrow')
    
function localSetFlterType(eventSrc,eventData,h)

%% Filter type combo callback which sets the filter rule
filter_types = {'firstord','transfer','ideal'};
h.Filter = filter_types{get(eventSrc,'Value')};
    
function localFilterTypeChange(eventSrc,eventData,h,Handles)

%% Filterrule Filter property callback which changes the filter definition
%% panel visibility
switch h.Filter
    case 'firstord'
        set(Handles.PNLtransfcn,'Visible','off')
        set(Handles.PNLideal,'Visible','off')
        set(Handles.PNLtimeconst,'Visible','on')       
    case 'transfer'
        set(Handles.PNLtimeconst,'Visible','off')
        set(Handles.PNLideal,'Visible','off')
        set(Handles.PNLtransfcn,'Visible','on')       
    case 'ideal'
        set(Handles.PNLtransfcn,'Visible','off')
        set(Handles.PNLtimeconst,'Visible','off')
        set(Handles.PNLideal,'Visible','on')
end

function localParseFilterSpec(eventSrc,eventData,h,prop,defaultVal)

%% Parses filter specifications - resetting invalid entries
try
    numval = eval(get(eventSrc,'String'));
catch %#ok<CTCH>
    numval = [];
end
if isempty(numval)
    set(eventSrc,'String',defaultVal) % Reset to default
else
    set(h,prop,numval) % Set the object property to the evaluated value
end
 
function localAnyAllChange(es,ed,h)

%% Callback for any/all combo
offon = {'off';'on'};
set(h,'Rowor',offon{get(es,'Value')})


function localUndoActive(es,ed,UndoButtons,r)

%% Callback to transaction recorder listener which regulates the nable
%% status of the Undo buttons

for k=1:length(UndoButtons)
    if ~isempty(getappdata(UndoButtons(k),'Transaction')) && ~isempty(r.Undo) && ...
            getappdata(UndoButtons(k),'Transaction') == r.Undo(end)
        set(UndoButtons(k),'Enable','on')
    else
        set(UndoButtons(k),'Enable','off')
    end
end

function localApply(es,ed,h,TabName,thisUndoButton)

try % Prevent unexpected command line errors
    set(h.Figure,'Pointer','watch')

    %% Evaluate the operations
    T = h.eval(TabName);
    if isempty(T)
        set(h.Figure,'Pointer','arrow')
        return
    end

    %% Locally cache the transaction
    setappdata(thisUndoButton,'Transaction',T);

    %% Commit the transaction
    r = tsguis.recorder;
    T.commit;
    r.pushundo(T);

    set(h.Figure,'Pointer','arrow')
catch %#ok<CTCH>
    set(h.Figure,'Pointer','arrow')
end


function localUpdateInterpTs(es,ed,h)

% Updates the Interpolation use other time series property.
if get(h.Handles.RADIOotherts,'Value')==1 && h.Handles.COMBotherts
    locTsList = get(h.Handles.COMBotherts,'String');
    locTsPos = get(h.Handles.COMBotherts,'Value');
    locTs = locTsList{locTsPos};
    if locTsPos>=1 && ~isempty(locTs)
       h.InterptsPath = locTs;
    else
        h.InterptsPath = '';
    end
else
    h.InterptsPath = '';
end