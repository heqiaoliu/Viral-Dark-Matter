function thisTab = freqpnl(view,h)

% Copyright 2004-2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import java.awt.*
import com.mathworks.mwswing.*;
import javax.swing.*;

%% Build freq panel
h.Handles.FreqPnl = localBuildPanel(h,view);
thisTab = struct('Name','Domain','Handles',[]);
thisTab.Name = 'Domain';
h.Tabs = [h.Tabs; thisTab];
outerFreqPanel = MJPanel(BorderLayout(5,5));
outerFreqPanel.add(h.Handles.FreqPnl,BorderLayout.CENTER);
h.Handles.TabPane.add(xlate('Define Frequency Vector'),outerFreqPanel);     

%% Listener to ViewChanged event which keeps the freq
%% panel updated
h.Listeners = [h.Listeners; handle.listener(view.AxesGrid,'ViewChange',...
    {@localRefresh h view})];
localRefresh([],[],h,view)
localUnitChange([],[],h,view)

function localUnitChange(es,ed,h,view)

%% Units combo callback. Note that the view change listener will
%% call the localRefresh fnc which will update the start and end edit
%% boxes

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
btn = uigettoolbar(ancestor(view.AxesGrid.Parent,'figure'),'Exploration.Pan');
pan(ancestor(view.AxesGrid.Parent,'figure'),'off');

%% Get the selected units and assign them to the axesgrid
view.AxesGrid.Xunits = h.Handles.FreqPnl_COMBOunits.getSelectedItem;
S = warning('off','all');
for k=1:length(view.Waves)
    view.Waves(k).DataSrc.send('sourcechange');
end
warning(S);

function mainPnl = localBuildPanel(h,view)

import java.awt.*
import com.mathworks.mwswing.*;
import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;

%% Build panel
mainPnl = MJPanel(BorderLayout(5,5));
FreqPnl = MJPanel(GridLayout(1,3));
PanningPnl = MJPanel(BorderLayout(5,5));
PanningPnl.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));

%% Create components for freq interval panel
LBLstart = MJLabel(xlate('Start frequency'));
h.Handles.FreqPnl_EDITstart = MJTextField(7);
set(handle(h.Handles.FreqPnl_EDITstart,'callbackproperties'),'ActionPerformedCallback',...
   {@localFreqUpdate h view});
set(handle(h.Handles.FreqPnl_EDITstart,'callbackproperties'),'FocusLostCallback',...
   {@localFreqUpdate h view});
LBLend = MJLabel(xlate('End frequency'));
h.Handles.FreqPnl_EDITend = MJTextField(7);
set(handle(h.Handles.FreqPnl_EDITend,'callbackproperties'),'ActionPerformedCallback',...
   {@localFreqUpdate h view});
set(handle(h.Handles.FreqPnl_EDITend,'callbackproperties'),'FocusLostCallback',...
   {@localFreqUpdate h view});
LBLunits = MJLabel(xlate('Units'));
h.Handles.FreqPnl_COMBOunits = MJComboBox;
set(handle(h.Handles.FreqPnl_COMBOunits,'callbackproperties'),...
    'ActionPerformedCallback',{@localUnitChange h view})
funits = strcat('cyc/',get(findtype('TimeUnits'),'Strings'));
for k=1:length(funits)
   thisunit = funits{k};
   thisunit = thisunit(1:end-1); % Strip the last s
   h.Handles.FreqPnl_COMBOunits.addItem(thisunit);
end

%% Create Help button
h.Handles.HelpButton = MJButton(xlate('Help'));
set(handle(h.Handles.HelpButton,'callbackproperties'),'ActionPerformedCallback',...
         'tsDispatchHelp(''pe_periodogram'',''modal'')');
helpPanel = MJPanel(BorderLayout);
helpPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
helpPanel.add(h.Handles.HelpButton,BorderLayout.EAST);

%% Create the panning panel
PanningPnl.add(MJLabel(xlate('Pan frequency axis')),BorderLayout.WEST);
h.Handles.FreqPanScroll = tsMatlabCallbackScrollBar;
h.Handle.ResetFreqBtn = MJButton(xlate('Reset'));
set(handle(h.Handle.ResetFreqBtn,'callbackproperties'),'ActionPerformedCallback',...
    {@localSetFreqAuto view});
h.Handles.FreqPanScroll.setOrientation(0);
PannerBox = Box(BoxLayout.Y_AXIS);
PannerBox.add(Box.createVerticalGlue());
PannerBox.add(h.Handles.FreqPanScroll);
PannerBox.add(Box.createVerticalGlue());
PanningPnl.add(PannerBox,BorderLayout.CENTER);
PanningPnl.add(h.Handle.ResetFreqBtn,BorderLayout.EAST);
h.Handles.FreqPanScroll.setCallback(view,{h});

%% Set the current units
funits = get(findtype('TimeUnits'),'Strings');
for k=1:length(funits)
    thisfunit = funits{k};
    funits{k} = sprintf('cyc/%s',thisfunit(1:end-1));
end
unitind = find(strcmp(view.Axesgrid.Xunits,funits));
if isempty(unitind)
    unitind = find(strcmp('cyc/second',funits));
end
h.Handles.FreqPnl_COMBOunits.setSelectedIndex(unitind-1);

%% Add components
FreqPnlLeft = MJPanel(BorderLayout(5,5));
FreqPnlLeft.add(LBLstart,BorderLayout.WEST);
FreqPnlLeft.add(h.Handles.FreqPnl_EDITstart,BorderLayout.CENTER);
FreqPnlLeftOuter = MJPanel(BorderLayout(5,5));
FreqPnlLeftOuter.add(FreqPnlLeft,BorderLayout.NORTH);
FreqPnlLeftOuter.setBorder(BorderFactory.createEmptyBorder(5,5,0,5));
FreqPnlRight = MJPanel(BorderLayout(5,5));
FreqPnlRight.add(LBLend,BorderLayout.WEST);
FreqPnlRight.add(h.Handles.FreqPnl_EDITend,BorderLayout.CENTER);
FreqPnlRightOuter = MJPanel(BorderLayout(5,5));
FreqPnlRightOuter.add(FreqPnlRight,BorderLayout.NORTH);
FreqPnlRightOuter.setBorder(BorderFactory.createEmptyBorder(5,5,0,5));
FreqPnlRightRight = MJPanel(BorderLayout(5,5));
FreqPnlRightRight.add(LBLunits,BorderLayout.WEST);
FreqPnlRightRight.add(h.Handles.FreqPnl_COMBOunits,BorderLayout.CENTER);
FreqPnlRightRightOuter = MJPanel(BorderLayout(5,5));
FreqPnlRightRightOuter.setBorder(BorderFactory.createEmptyBorder(5,5,0,5));
FreqPnlRightRightOuter.add(FreqPnlRightRight,BorderLayout.NORTH);
FreqPnl.add(FreqPnlLeftOuter);
FreqPnl.add(FreqPnlRightOuter);
FreqPnl.add(FreqPnlRightRightOuter);
FreqOutPnl = MJPanel(BorderLayout);
FreqOutPnl.add(FreqPnl,BorderLayout.NORTH);

%% Assemble panel

mainPnl.add(FreqOutPnl,BorderLayout.NORTH);
panningOutPanel = MJPanel(BorderLayout(5,5));
panningOutPanel.add(PanningPnl,BorderLayout.NORTH);
mainPnl.add(panningOutPanel,BorderLayout.CENTER);
mainPnl.add(helpPanel,BorderLayout.SOUTH);

function localFreqUpdate(eventSrc,eventData,h,view)

%% Callback for start and end time edit boxes which updates the AxesGrid

%% Quick return if plot is being deleted
if isempty(view) || ~ishandle(view)
    return
end

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
btn = uigettoolbar(ancestor(view.AxesGrid.Parent,'figure'),'Exploration.Pan');
pan(ancestor(view.AxesGrid.Parent,'figure'),'off');

%% Get the start and end times from the edit boxes and apply them to the
%% axesgrid
startfreq = eval(h.Handles.FreqPnl_EDITstart.getText,'[]');
if isempty(startfreq) || ~isscalar(startfreq) || ~isfinite(startfreq)
    localRefresh([],[],h,view) 
    %startfreq = 0;
    return
end
endfreq = eval(h.Handles.FreqPnl_EDITend.getText,'[]');
if isempty(endfreq) || ~isscalar(endfreq) || ~isfinite(endfreq) || ...
        endfreq<=startfreq
    localRefresh([],[],h,view)
    %endfreq = inf;
    return
end
view.AxesGrid.setxlim([startfreq endfreq]);

function localRefresh(es,ed,h,view)
%% Callback for ViewChanged listener which keeps the freq domain
%% panel updated

xlim = num2cell(view.AxesGrid.getxlim(1));
units = h.Handles.FreqPnl_COMBOunits.getSelectedItem;
awtinvoke(h.Handles.FreqPnl_EDITstart,'setText(Ljava.lang.String;)',...
    sprintf('%0.2g',xlim{1}));
awtinvoke(h.Handles.FreqPnl_EDITend,'setText(Ljava.lang.String;)',...
    sprintf('%0.2g',xlim{2}));

%% Update the panner
%if strcmp(view.AxesGrid.LimitManager,'on')
    freqExtent = view.getExtent;
    xlims = view.AxesGrid.getxlim{1};
    pannerPos = 100*(mean(xlims)-freqExtent(1))/(freqExtent(2)-freqExtent(1)); 
    pannerPos = max(min(pannerPos,100),0);
    if abs(pannerPos-h.Handles.FreqPanScroll.getValue)>2
        panScaleFact = 100/(100-h.Handles.FreqPanScroll.getModel.getExtent);
        h.Handles.FreqPanScroll.setValueNoCallback(pannerPos/panScaleFact);
    end
%end

function localSetFreqAuto(es,ed,h)

%% Get out of pan mode, since depressing the panner button has turned off
%% the limit manager.
btn = uigettoolbar(ancestor(h.AxesGrid.Parent,'figure'),'Exploration.Pan');
pan(ancestor(h.AxesGrid.Parent,'figure'),'off');

h.AxesGrid.xlimmode = 'auto';
% Must recompute foci if data has changed
for k=1:length(h.waves)
    h.waves(k).DataSrc.send('sourcechange');
end
h.AxesGrid.LimitManager = 'on';
h.AxesGrid.send('viewchange')