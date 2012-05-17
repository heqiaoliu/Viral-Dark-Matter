function buildeditor(Editor)
%BUILDEDITOR  Builds the pzeditor GUI

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2008/12/04 22:24:40 $

import java.awt.*;

%% Create combo and transfer function panel
ComboDispHandles = buildcompdisppanel(Editor);

%% Create tabbed pane for pz editor and block parameter editor
TabbedPane = javaObjectEDT('com.mathworks.mwswing.MJTabbedPane');
TabbedPane.setName('TabbedPane')
% Create a tab for each compensator and initialize it
PZTabHandles = buildcomptab_PZEditor(Editor);  
TabbedPane.addTab(xlate('Pole/Zero'), PZTabHandles.PTab);
ParaTabHandles = buildcomptab_ParaEditor(Editor);  
TabbedPane.addTab(xlate('Parameter'), ParaTabHandles.PTab);
% listen for change in tabs
h = handle(TabbedPane, 'callbackproperties' );
h.StateChangedCallback = {@localRefreshTab, Editor};

%% Create MainPanel for compensator editor
MainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0,5));
% Add items to Main panel
tmpPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
tmpBox = javaMethodEDT('createRigidArea','javax.swing.Box',Dimension(0,5));
tmpPanel.add(tmpBox,BorderLayout.NORTH);
tmpPanel.add(ComboDispHandles.Combopanel, BorderLayout.SOUTH);
MainPanel.add(tmpPanel,BorderLayout.NORTH);
MainPanel.add(TabbedPane,BorderLayout.CENTER);

% save handles
Editor.Handles = struct(...
    'Panel', MainPanel, ...
    'TabbedPane', TabbedPane, ...
    'ComboDispHandles', ComboDispHandles, ...    
    'ParaTabHandles', ParaTabHandles, ...    
    'PZTabHandles', PZTabHandles);


%% ------------------------Callback Functions--------------------------------
% ------------------------------------------------------------------------%
% Function: LocalRefreshTab
% Purpose:  tab changes
% ------------------------------------------------------------------------%
function localRefreshTab(hsrc,event,Editor)
if ishandle(Editor)
    Editor.refreshpanel;
end
