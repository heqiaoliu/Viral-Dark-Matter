function createExplorer(h)
%  createExplorer
%  
%  Creates a "diagnostic message explorer," a customized instance of the 
%  ModelExplorer. The Diagnostic Viewer displays messages in the message
%  explorer instances. 
% 
%  Copyright 2008 The MathWorks, Inc.
 
 % Create a message container to serve as the root of the tree of
 % objects to be displayed by the Explorer. The DV displays messages by
 % making them children of the root object. Each message displays its 
 % content in a dialog that appears in the Explorer's dialog view. The
 % actual message content appears in a browser widget residing in the
 % message dialog.
 msgTreeRoot = DAStudio.DiagMsgContainer;
 
 if isempty(h.Messages)
   msgTreeRoot.children = h.NullMessage;
   msgTreeRoot.children(1).connect(msgTreeRoot, 'up');
 else
   % Connect new messages to the message container.
   for i = 1:length(h.Messages)
     h.Messages(i).connect(msgTreeRoot, 'up');      
   end     
   % Add messages  to the window
   msgTreeRoot.children = h.Messages;
 end
 
 % Create a hidden instance of the Explorer.
 h.Explorer = DAStudio.Explorer(msgTreeRoot, 'Diagnostic Viewer', false);
 
 % The following is intended to prevent the DV's instance from responding
 % to MESleep/WakeEvent events issued by anybody but the DV itself. This
 % is necessary because other applications, e.g., Stateflow, broadcast
 % these events, targeting the real "Model Explorer" instance. If the 
 % DV's Explorer listens to these external sleep events, it can fail to
 % notice changes to the contents of the DV's message container, which in
 % turn can lead to MATLAB crashes. See the DV's updateWindow method for
 % a case where the DV itself issues sleep/wake events.
 h.Explorer.setDispatcherEvents({'FocusChangedEvent'});
 
 % Hide the Explorer's tree view.
 h.Explorer.showTreeView(false);
 
 % Hide the "Contents of" field at the top of the list view.
 h.Explorer.showContentsOf(false);
 
 % Layout the Explorer with the list view on top of the dialog view
 % instead of beside it. The list view displays key properties of each
 % message residing in the Explorer's message tree. Selecting a row in
 % the list view displays the corresponding message's dialog in the
 % Explorer's dialog view.
 h.Explorer.setDlgListViewLayoutVert(true);
 h.Explorer.setListMultiSelect(false);
 
 % Ensure that the Explorer displays a message's dialog in its entirety.
 % The dialog's text browser widget shows scrollbars if the message
 % content cannot fit entirely in the dialog.
 h.Explorer.setDlgViewScrollable(false);
 
 % Set the Explorer's initial position (center of screen) and size
 % (300 pixels wide by 200 pixels high).
 screen_size = get(0, 'screensize');
 pos(1) = screen_size(3)/2 - 300;
 pos(2) = screen_size(4)/2 - 200;
 pos(3) = 600;
 pos(4) = 400;
 h.setPosition(pos);
 
 % State variable to ensure that the list view height is initialized
 % only once. Thereafter, the user controls the height.
 h.msgListViewHeightInitialized = false;
 
 % Specifies user-friendly aliases for some of the message properties
 % displayed in the list view.
 h.Explorer.addPropDisplayNames( ...
   {'DispType'   DAStudio.message('Simulink:components:DVMessage') ...
    'SourceName' DAStudio.message('Simulink:components:DVSource') ...
    'Component'  DAStudio.message('Simulink:components:DVReportedBy') ...
    'Summary'    DAStudio.message('Simulink:components:DVSummary')});
  
 % Size the list view column widths to be wide enough to accommodate
 % the widest text that appears in the columns.
 h.setColumnWidths();
 
 % Initialize to reflect new batch of messages.
 h.selectedMsg = [];
 
 % Specify icon that appears in upper left corner of Explorer window.
 iconPath = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', ...
                     'resources', 'diagviewer', 'viewer_icon.gif');
 if exist(iconPath, 'file') == 2
   h.Explorer.icon = iconPath;
 end
 
 h.Explorer.set('title', h.Title);

 % Create the Explorer menu bar.
 createMenubar(h, h.Explorer);                         
                           
 h.installWindowCloseListener;
 h.installMsgSelectionListener;
 h.installWindowPostShowListener; 
 h.installWindowDeleteListener;
 h.installPropListChangedListener;
 
end

function createMenubar(dv, me)
    am = DAStudio.ActionManager;
    am.initializeClient(me);
  
    
    % Create View menu
    menu = am.createPopupMenu(me);
    
    dv.propShowActions = {};
    
    item = am.createAction(me, 'Text', ...
      DAStudio.message('Simulink:components:DVShowMsg'), ...
      'Callback', 'DAStudio.DiagViewer.updateListView;', ...
      'ToggleAction', 'on', 'On', 'off');
    item.StatusTip = DAStudio.message('Simulink:components:DVShowMsgTip');
    dv.showMessageAction = item;
    dv.propShowActions = [dv.propShowActions {{'DispType', item}}];
    menu.addMenuItem(item);
    
    initProps = dv.msgListProps;
    
    if ismember('DispType', initProps)
      dv.ShowMessageAction.On = 'on';
    end
    
    item = am.createAction(me, 'Text', ...
      DAStudio.message('Simulink:components:DVShowSrc'), ...
      'Callback', 'DAStudio.DiagViewer.updateListView;', ...
      'ToggleAction', 'on', 'On', 'off');
    item.StatusTip = DAStudio.message('Simulink:components:DVShowSrcTip');
    dv.showSourceAction = item;
    dv.propShowActions = [dv.propShowActions {{'SourceName', item}}];
    menu.addMenuItem(item);
    
    if ismember('SourceName', initProps)
      dv.ShowSourceAction.On = 'on';
    end
    
    item = am.createAction(me, 'Text', ...
      DAStudio.message('Simulink:components:DVShowReportedBy'), ...
      'Callback', 'DAStudio.DiagViewer.updateListView;', ...
      'ToggleAction', 'on', 'On', 'off');
    item.StatusTip = DAStudio.message('Simulink:components:DVShowReportedByTip');
    dv.showReportedAction = item;
    dv.propShowActions = [dv.propShowActions {{'Component', item}}];
    menu.addMenuItem(item);
    
    if ismember('Component', initProps)
      dv.ShowReportedAction.On = 'on';
    end

    
    item = am.createAction(me, 'Text', ...
      DAStudio.message('Simulink:components:DVShowSummary'), ... 
      'Callback', 'DAStudio.DiagViewer.updateListView;', ...
      'ToggleAction', 'on', 'On', 'off');
    item.StatusTip = DAStudio.message('Simulink:components:DVShowSummaryTip');
    dv.showSummaryAction = item;
    dv.propShowActions = [dv.propShowActions {{'Summary', item}}];
    menu.addMenuItem(item);

    if ismember('Summary', initProps)
      dv.ShowSummaryAction.On = 'on';
    end

    am.addSubMenu(me, menu, '&View');
    
    % Create Font Size menu
    menu = am.createPopupMenu(me);
    
    item = am.createDefaultAction(me,'VIEW_INCREASEFONT');
    menu.addMenuItem(item);
    
    item = am.createDefaultAction(me,'VIEW_DECREASEFONT');
    menu.addMenuItem(item);
         
    am.addSubMenu(me, menu, DAStudio.message('Simulink:components:DVFontSize'));

end
  