function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Set the callbacks for the menu items and toolbar buttons.

% Author(s): John Glass, B. Eryilmaz
% Revised:
%   Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/03/13 17:39:38 $

% Create menubar
menubar = javaObjectEDT('com.mathworks.toolbox.control.explorer.MenuBar',...
                     this.getGUIResources, manager.Explorer);

% Create toolbar
toolbar = javaObjectEDT('com.mathworks.toolbox.control.explorer.ToolBar',...
                    this.getGUIResources, manager.Explorer );

% General Items
GenericLinearizationNodes.addGeneralMenuToolbarListeners(this,menubar,toolbar,manager);

% Simulink SISOTOOL Task Tools Menu
h = handle( menubar.getMenuItem('settings'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalSimulinkSISOTOOLTaskOptions(this)}));

% Export Menu
h = handle( menubar.getMenuItem('export'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalExport(this.sisodb)}));

% undo Menu
h1 = handle( menubar.getMenuItem('undo'), 'callbackproperties' );
h2 = handle( toolbar.getToolbarButton('undo'), 'callbackproperties' );
this.addListeners(handle.listener([h1;h2], 'actionPerformed', {@(es,ed) LocalUndo(this.sisodb)}));
javaMethodEDT('setEnabled',menubar.getMenuItem('undo'),false);

% redo Menu
h1 = handle( menubar.getMenuItem('redo'), 'callbackproperties' );
h2 = handle( toolbar.getToolbarButton('redo'), 'callbackproperties' );
this.addListeners(handle.listener([h1;h2], 'actionPerformed', {@(es,ed) LocalRedo(this.sisodb)}));
javaMethodEDT('setEnabled',menubar.getMenuItem('redo'),false);

% Preference Menu
h = handle( menubar.getMenuItem('prefs'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalEditPrefs(this.sisodb)}));

% What is Compensator Design Help
h = handle( menubar.getMenuItem('whatiscompdes'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('what_is_compensator_design')}));

% Selecting Tunable Blocks Help
h = handle( menubar.getMenuItem('selecttuneblock'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('select_tunable_blocks')}));

% IO Help
h = handle( menubar.getMenuItem('clsigs'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('closed_loop_signals')}));

% Operating Point Spec
h = handle( menubar.getMenuItem('opspec'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('op_points')}));

% Analysis Plots
h = handle( menubar.getMenuItem('anplts'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('config_design_analysis_plots')}));

% Complete SISODESIGN
h = handle( menubar.getMenuItem('completedes'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('complete_siso_design')}));

% Install listener for enable state
Recorder = this.sisodb.EventManager.EventRecorder;
this.Handles.UndoListener = handle.listener(Recorder,findprop(Recorder,'Undo'),...
   'PropertyPostSet',{@LocalDoMenu menubar.getMenuItem('undo') toolbar.getToolbarButton('undo') 1});

this.Handles.RedoListener = handle.listener(Recorder,findprop(Recorder,'Redo'),...
   'PropertyPostSet',{@LocalDoMenu menubar.getMenuItem('redo') toolbar.getToolbarButton('redo') 0});

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSimulinkSISOTOOLTaskOptions
function LocalSimulinkSISOTOOLTaskOptions(this)

% Call the constructor that displays the options
dlg = jDialogs.SimulinkSISOTOOLTaskOptionsDialog(this);

% Put the dialog on top of the explorer
dlg.JavaPanel.pack
javaMethodEDT('setLocationRelativeTo',dlg.JavaPanel,slctrlexplorer);
javaMethodEDT('setVisible',dlg.JavaPanel,true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUndo 
function LocalUndo(sisodb)
% Undo callback
StackLength = length(sisodb.EventManager.EventRecorder.Undo);
% Prevent undo if stack is less then desired length g229541
if StackLength > 1
    sisodb.EventManager.undo;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRedo
function LocalRedo(sisodb)
% Redo callback
StackLength = length(sisodb.EventManager.EventRecorder.Redo);
% Prevent redo if stack is less then desired length g229541
if StackLength > 0
   sisodb.EventManager.redo;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDoMenu
function LocalDoMenu(hProp,event,hMenu,hToolBar,MinStackLength)
% Update menu state and label
Stack = event.NewValue;
if length(Stack)<=MinStackLength
    % Empty stack
    hMenu.setText(sprintf('&%s',get(hProp,'Name')))
    menustate = false;
else
    % Get last transaction's name
    ActionName = Stack(end).Name;
    Label = sprintf('&%s %s',get(hProp,'Name'),ActionName);
    hMenu.setText(Label)
    menustate = true;
end
javaMethodEDT('setEnabled',hMenu,menustate);
javaMethodEDT('setEnabled',hToolBar,menustate);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalEditPrefs
function LocalEditPrefs(sisodb)
% Edit SISO Tool prefs 
edit(sisodb.Preferences); 


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalExport
function LocalExport(sisodb)
% Opens export dialog
sisodb.DesignTask.showExportDialog;




