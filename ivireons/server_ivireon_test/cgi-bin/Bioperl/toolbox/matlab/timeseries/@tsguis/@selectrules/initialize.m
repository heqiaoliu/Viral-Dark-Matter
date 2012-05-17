function initialize(h)
%% Builds the Data Selection GUI

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2009/06/16 04:20:11 $

import javax.swing.*; 
import java.awt.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

%% Selection rules
h.Rules = tsguis.exclusion;

%% Main figure
h.Figure = figure('Units','Characters','Position',[104 31.2989 100 31],'Toolbar','None',...
    'Menubar','None','NumberTitle','off','Name','Select Data Using Rules',...
    'Visible','off','closeRequestFcn',@(es,ed) set(h,'Visible','off'),...
    'HandleVisibility','callback','IntegerHandle','off');

%% Build buttons
h.Handles.BTNok = uicontrol('Style','Pushbutton','String','OK','Parent',h.Figure,'Units','Characters',...
    'Callback',{@localOK h},'BusyAction','Cancel','Interruptible','off');
h.Handles.BTNapply = uicontrol('Style','Pushbutton','String','Apply','Parent',h.Figure,'Units','Characters',...
    'callback',{@localApply h},'BusyAction','Cancel','Interruptible','off');
h.Handles.BTNcancel = uicontrol('String','Cancel','Parent',h.Figure,'Units','Characters',...
    'Callback',@(es,ed) set(h,'Visible','off'));
h.Handles.BTNhelp = uicontrol('String','Help','Parent',h.Figure,'Units','Characters','Callback',...
    @(es,ed) tsDispatchHelp('d_select_data_on_plot','modal',h.Figure));

%% Build selection criteria panel
JAVAselectPanel = localBuildJavaSelection(h);
wrapPanel = javaObjectEDT('javax.swing.JPanel',GridLayout(1,1)); % work around for G232843
javaMethodEDT('add',wrapPanel,JAVAselectPanel);
javaMethodEDT('setOpaque',wrapPanel,true); 
[~, h.Handles.jPNLselection] = javacomponent(wrapPanel,[20 20 60 20],h.Figure);
set(h.Handles.jPNLselection,'Parent',h.Figure,'Units','Pixels');

%% Top Time series selection panel
h.Handles.TSPanel = uipanel('Parent',h.Figure,'ResizeFcn',{@localTsPanelResize h});
set(h.Handles.TSPanel,'Units','Characters',...
    'Title',xlate('Select the Time Plot and Time Series'));
h.Handles.LBLselts = uicontrol('style','text','String','Select the time plot','Units',...
    'Characters','Parent',h.Handles.TSPanel);
h.Handles.COMBOselectView = uicontrol('style','popupmenu','String',{'  '},'Units',...
    'Characters','Parent',h.Handles.TSPanel,'Callback', ...
    {@localSwitchView h});
if ~ismac
    set(h.Handles.COMBOselectView,'BackgroundColor',[1 1 1]);
end


h.Handles.tsTableModel = tsMatlabCallbackTableModel(cell(0,4),...
            {xlate('Select from (y/n)?'),xlate('Time Series'),xlate('Path'),xlate('Selected Column(s)')},...
            [],[]);
h.Handles.tsTableModel.setNoEditCols([1 2]);   
drawnow
h.Handles.tsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.tsTableModel);
h.Handles.tsTable.setName('selectrules:tstable');
javaMethod('setPreferredWidth',h.Handles.tsTable.getColumnModel.getColumn(2),...
    200);
javaMethod('setAutoResizeMode',h.Handles.tsTable,JTable.AUTO_RESIZE_OFF);
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',h.Handles.tsTable);
[~, h.Handles.tsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
c = javaObjectEDT('javax.swing.JCheckBox');
javaMethod('setCellEditor',h.Handles.tsTable.getColumnModel.getColumn(0),...
    DefaultCellEditor(c));
javaMethod('setCellRenderer',h.Handles.tsTable.getColumnModel.getColumn(0),...
    tsCheckBoxRenderer);
set(h.Handles.tsTablePanel,'Parent',h.Handles.TSPanel,'Units','Pixels');

% 1st column is HTML
h.ViewNode.getRoot.setHTMTableColumn(h.Handles.tsTable,2);

% Make th figure background color match the uipanel color
set(h.Figure,'Color',get(h.Handles.TSPanel,'BackGroundColor'))

% Install listeners
h.generic_listeners

% Layout
set(h.Figure,'ResizeFcn',{@localFigResize h})
localFigResize(h.Figure,[],h);


%--------------------------------------------------------------------------
function dataSelectionPanel =  localBuildJavaSelection(h)

% Builds the java tabbed panel which defines selection rules

import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.page.utils.VertFlowLayout;
import java.awt.*;
import javax.swing.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build Bounds Panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataSelectionPanel = javaObjectEDT('com.mathworks.toolbox.timeseries.DataSelectionPanel');
h.Handles.TXTTimeTop = dataSelectionPanel.getDataSelectionBoundsPanel.getTopTimeTextField;
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getTopTimeButton(),'callbackproperties'),'ActionPerformedCallback',...
    {@localCalendar h h.Handles.TXTTimeTop})
h.Handles.TXTTimeBottom = dataSelectionPanel.getDataSelectionBoundsPanel.getBottomTimeTextField();
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getBottomTimeButton(),'callbackproperties'),'ActionPerformedCallback',...
    {@localCalendar h h.Handles.TXTTimeBottom})
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getUndoSelectButton(),'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,''});
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getSelectButton(),'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,'Bounds'});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add time panel callbacks
timeChangeCallback = {@localBound h h.Handles.TXTTimeTop h.Handles.TXTTimeBottom ...
    dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboTop() dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboBottom()  'time'};
set(handle(h.Handles.TXTTimeTop,'callbackproperties'),'ActionPerformedCallback',...
    timeChangeCallback,'FocusLostCallback',timeChangeCallback)
set(handle(h.Handles.TXTTimeBottom,'callbackproperties'),'ActionPerformedCallback',...
    timeChangeCallback,'FocusLostCallback',timeChangeCallback)
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboTop(),'callbackproperties'),'ActionPerformedCallback',...
    timeChangeCallback,'FocusLostCallback',timeChangeCallback)
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboBottom(),'callbackproperties'),'ActionPerformedCallback',...
    timeChangeCallback,'FocusLostCallback',timeChangeCallback)
dataChangeCallback = {@localBound h dataSelectionPanel.getDataSelectionBoundsPanel.getDataTextFieldTop() dataSelectionPanel.getDataSelectionBoundsPanel.getDataTextFieldBottom() ...
    dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboTop() dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboBottom() 'data'};
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getDataTextFieldTop(),'callbackproperties'),'ActionPerformedCallback',...
    dataChangeCallback,'FocusLostCallback',dataChangeCallback)
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getDataTextFieldBottom(),'callbackproperties'),'ActionPerformedCallback',...
    dataChangeCallback,'FocusLostCallback',dataChangeCallback)
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboTop(),'callbackproperties'),'ActionPerformedCallback',...
    dataChangeCallback,'FocusLostCallback',dataChangeCallback)
set(handle(dataSelectionPanel.getDataSelectionBoundsPanel.getTimeOrderingComboBottom(),'callbackproperties'),'ActionPerformedCallback',...
    dataChangeCallback,'FocusLostCallback',dataChangeCallback)

%% Add outlier callbacks
set(handle(dataSelectionPanel.getOutlierPanel.getUndoSelectButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,''});
set(handle(dataSelectionPanel.getOutlierPanel.getSelectButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,'Outliers'});
outlierCallback = {@localOutlier h.rules dataSelectionPanel.getOutlierPanel.getWindowTextField dataSelectionPanel.getOutlierPanel.getConfTextField};
set(handle(dataSelectionPanel.getOutlierPanel.getWindowTextField,'callbackproperties'),'ActionPerformedCallback',...
    outlierCallback,'FocusLostCallback',outlierCallback)
set(handle(dataSelectionPanel.getOutlierPanel.getConfTextField,'callbackproperties'),'ActionPerformedCallback',...
    outlierCallback,'FocusLostCallback',outlierCallback)

%% Add MATLAB expression callbacks
set(handle(dataSelectionPanel.getExpressionPanel.getUndoSelectButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,''});
set(handle(dataSelectionPanel.getExpressionPanel.getSelectButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,'Expression'});
expressioncallback = {@localExpression h.rules dataSelectionPanel.getExpressionPanel.getTxtExpression}; 
set(handle(dataSelectionPanel.getExpressionPanel.getTxtExpression,'callbackproperties'),'ActionPerformedCallback',...
    expressioncallback,'FocusLostCallback',expressioncallback)

%% Add flatline callbacks
set(handle(dataSelectionPanel.getFlatLinePanel.getUndoSelectButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,''});
set(handle(dataSelectionPanel.getFlatLinePanel.getSelectButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localApply h,'Flatline'});
flatlinecallback = {@localFlatline h.rules dataSelectionPanel.getFlatLinePanel.getTxtFlatline};
set(handle(dataSelectionPanel.getFlatLinePanel.getTxtFlatline,'callbackproperties'),'ActionPerformedCallback',...
    flatlinecallback,'FocusLostCallback',flatlinecallback)

%--------------------------------------------------------------------------
function localSwitchView(eventSrc,~, h)

%% View combo callback which changes the viewNode
ind = get(eventSrc,'Value');
views = get(eventSrc,'Userdata');
h.ViewNode = views(ind);

%--------------------------------------------------------------------------
function emptyset = localApply(~,~,h,varargin)

try % Prevent command line errors
    recorder = tsguis.recorder;
    set(h.Figure,'Pointer','watch')

    %% Find the selected time series and columm after finishing editing
    celleditor = h.Handles.tsTable.getCellEditor;
    if ~isempty(celleditor)
        awtinvoke(celleditor,'stopCellEditing()');
        drawnow
    end

    %% Find the time series to be used for selection
    tsTableData = cell(h.Handles.tsTable.getModel.getData);
    tsList = {};
    selectedCols = {};
    for k=1:size(tsTableData,1)
        if tsTableData{k,1}
            thists = h.ViewNode.getRoot.getts(tsTableData{k,3});
            thists = thists{1};
            try
                thesecols = eval(tsTableData{k,4});
            catch me %#ok<NASGU>
                thesecols = [];
            end
            if ~isempty(thists) && ~isempty(thesecols) && all(thesecols>=1) && ...
                    all(thesecols<=size(thists.Data,2))
                tsList = [tsList(:); {thists}];
                selectedCols = [selectedCols; {thesecols}]; %#ok<AGROW>
            else
                errordlg(sprintf('Invalid columns entered for time series %s.',thists.Name),...
                    'Time Series Tools','modal')
                set(h.Figure,'Pointer','arrow')
                return
            end
        end
    end

    %% Move the current plot into the foreground. This must be done to prevent
    %% HG from incorrectly setting the toolbar mode of the Selection dialog
    %% figure in response to setting the Plot figure into selection mode
    figure(ancestor(h.ViewNode.Plot.AxesGrid.Parent,'figure'))

    %% Exit normalizition mode so that the selected curves will display
    %% correctly
    h.Viewnode.Plot.axesgrid.YNormalization = 'off';

    %% For each selected time series and columns make the selection
    h.ViewNode.Plot.setselectmode('DataSelect');
    emptyset = true;
    for k=1:length(tsList)
        %% Find selected points
        s = size(tsList{k}.Data);
        I = false(s);
        I(:,selectedCols{k}) = true;
        if nargin>=4
            [ind, History] = h.Rules.feval(tsList{k},varargin{1});
        else
            [ind, History] = h.Rules.feval(tsList{k});
        end
        I = I & ind;
        if strcmp(recorder.Recording,'on') 
            if ~isequal(selectedCols{k},1:size(tsList{k}.Data,2))
             h.ViewNode.Plot.SelectionStruct.History = [h.ViewNode.Plot.SelectionStruct.History;...
                History;... 
               {xlate('%% Restricting rule selection to specified columns')};...
               {[ 'I' tsList{k}.Name ' = false(size(' tsList{k}.Name '.Data));' ]};... 
               {[ 'I' tsList{k}.Name '(:,[' num2str(selectedCols{k}) ']) = true;' ]};...
               {xlate('%% Applying combined selection rules')};...
               {[ 'I' tsList{k}.Name '= I' tsList{k}.Name ' & idx;' ]}];
            else
              h.ViewNode.Plot.SelectionStruct.History = [h.ViewNode.Plot.SelectionStruct.History;...
                                                         History;...
                                                         {[ 'I' tsList{k}.Name '= idx;' ]}];               
            end
        end  
        h.ViewNode.Plot.select(tsList{k},I);
        if any(I(:))
           emptyset = false;
        end
    end

    %% Warn about empty set 
    if nargin<=3 &&  emptyset
        drawnow
        warndlg('The combination of the selection rules identifies an empty set (no selection).',...
            'Time Series Tool','modal')
    end

    set(h.Figure,'Pointer','arrow')
catch me %#ok<NASGU>
    set(h.Figure,'Pointer','arrow')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Panel callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function localBound(~,~, h, TXTTop, TXTBottom, ...
    COMBOOrderingTop, COMBOOrderingBottom, type)

%% Time/Data bounds change callback - update rules object

try %#ok<TRYNC> % Prevent command line errors
    
    %% Get ordering combo values
    combVal{1} = COMBOOrderingTop.getSelectedItem;
    combVal{2} = COMBOOrderingBottom.getSelectedItem;

    %% Get bounds
    if strcmp(type,'time') && ~isempty(h.ViewNode.Plot) && ...
            strcmp(h.viewnode.getPlotTimeProp('AbsoluteTime'),'on')
         topdate = char(TXTTop.getText);
         bottomdate = char(TXTBottom.getText);
         if ~isempty(topdate)
             try
                 data{1} = datenum(topdate);
             catch me %#ok<NASGU>
                 errordlg('Time bounds must be valid date strings.',...
                     'Time Series Tools','modal')
                 awtinvoke(TXTTop,'setText(Ljava.lang.String;)',...
                     h.viewnode.getPlotTimeProp('StartDate'));
                 return
             end
         else
             data{1} = [];
         end
         if ~isempty(bottomdate)
             try
                 data{2} = datenum(bottomdate);
             catch me %#ok<NASGU>
                 errordlg('Time bounds must be valid date strings',...
                     'Time Series Tools','modal')
                 awtinvoke(TXTBottom,'setText(Ljava.lang.String;)',...
                     h.viewnode.getPlotTimeProp('StartDate'));
                 return
             end
         else
             data{2} = [];
         end
    else    
         toptime = char(TXTTop.getText);
         bottomtime = char(TXTBottom.getText);
         if ~isempty(toptime)
             try
                 data{1} = eval(toptime);
             catch me %#ok<NASGU>
                 data{1} = [];
             end
             if isempty(data{1})
                 awtinvoke(TXTTop,'setText(Ljava.lang.String;)','');
             end
         else
             data{1} = [];
         end
         if ~isempty(bottomtime)
             try
                 data{2} = eval(bottomtime);
             catch me %#ok<NASGU>
                 data{2} = [];
             end
             if isempty(data{2})
                 awtinvoke(TXTBottom,'setText(Ljava.lang.String;)','');
             end
         else
             data{2} = [];
         end
    end

    %% Initialize
    high = [];
    low = [];
    highstrict = 'off';
    lowstrict = 'off';

    %% Update the "exclusion" object to reflect the bounds panel
    for k=1:2
        switch combVal{k}
           case '<'
              if ~isempty(data{k}) && (isempty(low) || data{k}>=low)
                 low = data{k};
                 lowstrict = 'on';   
              end
           case '<=' 
              if ~isempty(data{k}) && (isempty(low) || data{k}>=low)
                 if data{k}<low
                    lowstrict = 'off';
                 end
                 low = data{k};
              end
           case '>'
              if ~isempty(data{k}) && (isempty(high) || data{k}<=high)
                 high = data{k};
                 highstrict = 'on';
              end
           case '>=' 
              if ~isempty(data{k}) && (isempty(high) || data{k}<=high)
                 if data{k}>high
                    highstrict = 'off';
                 end
                 high = data{k};
              end
        end
    end

    %% Write results to "exclusion" obj
    if isempty(h.ViewNode.Plot)
        return
    end
    if strcmp(type,'time')
        set(h.Rules,'Xlow',low,'Xhigh',high,'Xlowstrict',lowstrict,'Xhighstrict', ...
            highstrict,'Xunits',h.ViewNode.Plot.TimeUnits,...
            'AbsoluteTime',h.viewnode.getPlotTimeProp('AbsoluteTime'));
    else
        set(h.Rules,'Ylow',low,'Yhigh',high,'Ylowstrict',lowstrict,'Yhighstrict',...
            highstrict,'AbsoluteTime',h.viewnode.getPlotTimeProp('AbsoluteTime'));
    end
end
    
%--------------------------------------------------------------------------
function localOutlier(~,~,h,TXTWindow,TXTConf)

%% Outliers change callback - update rules object

try %#ok<TRYNC> % Prevent command line errors
    try
        winlen = eval(char(TXTWindow.getText));
    catch me1 %#ok<NASGU>
        winlen = [];
    end
    try 
        conf = eval(char(TXTConf.getText));
    catch me2 %#ok<NASGU>
        conf = [];
    end
    set(h,'Outlierwindow',winlen,'Outlierconf',conf);
end

function localOK(~,~, h)

%% OK button callback
set(h.Figure,'Pointer','watch')
emptyset = localApply([],[],h);
if ~emptyset
    h.Visible = 'off';
end
set(h.Figure,'Pointer','arrow')
%--------------------------------------------------------------------------
function localFlatline(~,~,h,TXTMaxLen)

%% Length must be >1, int,scalar

try %#ok<TRYNC>
    if isempty(deblank(char(getText(TXTMaxLen))))
        set(h,'Flatlinelength',[]);
        return
    end
    try
        flatlinelen = eval(char(getText(TXTMaxLen)));
    catch me %#ok<NASGU>
        flatlinelen = [];
    end
    if isempty(flatlinelen) || ~isscalar(flatlinelen) || ~isfinite(flatlinelen) || ...
            isnan(flatlinelen) || flatlinelen<2 || flatlinelen~=floor(flatlinelen)
        uiwait(errordlg('Length must be a finite integer >1,','Time Series Tools','modal')) 
        awtinvoke(TXTMaxLen,'setText(Ljava.lang.String;)','');
        set(h,'Flatlinelength',[]);
        return
    end
    try
        mxLen = eval(char(getText(TXTMaxLen)));
    catch me %#ok<NASGU>
        mxLen = [];
    end
    set(h,'Flatlinelength',mxLen)
end

%--------------------------------------------------------------------------
function localExpression(~,~,h,TXTExp)

%% Callback for MATLAB expression edit box

%% Evauate expression with x =1 to check that it is valid and returns a
%% logical
try %#ok<TRYNC> % Prevent command line errors
    x = 1; %#ok<NASGU>
    if isempty(char(TXTExp.getText))
        set(h,'Mexpression','')
        return
    end
    try
        outchk = eval(char(TXTExp.getText));
    catch me %#ok<NASGU>
        outchk = [];
    end
    %% If valid the process rule changle, else reset
    if ~isempty(outchk) && islogical(outchk)    
        set(h,'Mexpression',char(TXTExp.getText))
    else
        uiwait(errordlg('Expression must evaluate to a logical array,','Time Series Tools','modal'))
        set(h,'Mexpression','')
        awtinvoke(TXTExp,'setText(Ljava.lang.String;)','');
    end
end

%--------------------------------------------------------------------------
function localCalendar(~,~,h,TXTTime)

import com.mathworks.toolbox.timeseries.*;

%% Validation
if isempty(h.ViewNode.Plot)
    return
end
if strcmp(h.ViewNode.Plot.Absolutetime,'off')
    errordlg('Date strings can only be used for plots that use calendar dates.',...
        'Time Series Tools','modal')
    return
end

%% Create or open the calendar
if isempty(h.Calendar)
    h.Calendar = Calendar(TXTTime,xlate('Specify Date/Time'),TXTTime);
else
    h.Calendar.setTarget(TXTTime);
    awtinvoke(h.Calendar,'setVisible(Z)',true);
end

%% Use the current date to initialize the calendar, if it makes sense
h.Calendar.setSelectedDate(char(TXTTime.getText));


%--------------------------------------------------------------------------
%% Resize Functions
%--------------------------------------------------------------------------
function localFigResize(es,~,h)

%pos = get(es,'Position');
pos = hgconvertunits(h.Figure,get(es,'Position'),get(es,'Units'),...
        'Characters',h.Figure);  
    
%% Enforce minimum size
if pos(3)<65 || pos(4)<33
    pos(3) = max(pos(3),65);
    pos(4) = max(pos(4),33);
    set(es,'Position',pos);
    centerfig(es);
end
    
%% Resize buttons
set(h.Handles.BTNok,'Position',[pos(3)-62.4 0.6152 13.2 1.7687]);
set(h.Handles.BTNapply,'Position',[pos(3)-46.8 0.6152 13.2 1.7687]);
set(h.Handles.BTNcancel,'Position',[pos(3)-16.4-15 0.6152 13.2 1.7687]);
set(h.Handles.BTNhelp,'Position',[pos(3)-16.4 0.6152 13.2 1.7687]);

%% Time series panel
set(h.Handles.TSPanel,'Position',[2 18.5 pos(3)-5 pos(4)-20]);

%% Selection tabs
PanelPos = [2  0.769+3.1499  pos(3)-5 13.6897];
PixelPanelPos = hgconvertunits(h.Figure,PanelPos,'Characters',...
    'Pixels',h.Figure);
set(h.Handles.jPNLselection,'Position',PixelPanelPos)

function localTsPanelResize(es,~,h)

pos = hgconvertunits(h.Figure,get(es,'Position'),get(es,'Units'),...
        'Characters',h.Figure);    
%% Convert parent panel to pixels
tablePanelPos = [2.6  0.769  pos(3)-7 pos(4)-5];
PixelTablePanelPos = hgconvertunits(h.Figure,tablePanelPos,'Characters',...
    'Pixels',es);
set(h.Handles.tsTablePanel,'position',PixelTablePanelPos);

set(h.Handles.LBLselts,'Position',[3 pos(4)-3.5 19.2 1.1535])
set(h.Handles.COMBOselectView,'Position',[26 pos(4)-3.5 pos(3)-29.4 1.5380])
