function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Set the callbacks for the menu items and toolbar buttons.

% Author(s): John Glass, B. Eryilmaz
% Revised:
%   Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2009/08/08 01:19:15 $

Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkCompensatorDesignTask';

% Create menubar
menubar = javaObjectEDT('com.mathworks.toolbox.control.explorer.MenuBar',...
                     Resources, manager.Explorer);

% Create toolbar
toolbar = javaObjectEDT('com.mathworks.toolbox.control.explorer.ToolBar',...
                    Resources, manager.Explorer );                                              

% General Items
GenericLinearizationNodes.addGeneralMenuToolbarListeners(this,menubar,toolbar,manager);

% Preferences
h = handle( menubar.getMenuItem('perferences'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalPreferences()}));

% Settings Tools Menu
h = handle( menubar.getMenuItem('settings'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalLinearizationSettings(this)}));

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalPreferences
function LocalPreferences()

preferences('Simulink Control Design')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLinearizationSettings
function LocalLinearizationSettings(this)

% Call the constructor that displays the options
dlg = slctrlguis.optionsdlgs.getCompensatorDesignOptionsDialog(this);
dlg.show;
