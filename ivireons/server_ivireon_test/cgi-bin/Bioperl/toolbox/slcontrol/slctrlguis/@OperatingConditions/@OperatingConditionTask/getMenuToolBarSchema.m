function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Set the callbacks for the menu items and toolbar buttons.

% Author(s): John Glass, B. Eryilmaz
% Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.20 $ $Date: 2009/04/21 04:49:38 $

% Create menubar
menubar = javaObjectEDT('com.mathworks.toolbox.control.explorer.MenuBar',...
                     this.getGUIResources, manager.Explorer);

% Create toolbar
toolbar = javaObjectEDT('com.mathworks.toolbox.control.explorer.ToolBar',...
                    this.getGUIResources, manager.Explorer );

% General Items
GenericLinearizationNodes.addGeneralMenuToolbarListeners(this,menubar,toolbar,manager);

% Generate Code Menu
h = handle( menubar.getMenuItem('generateMCode'), 'callbackproperties' );
h2 = handle(toolbar.getToolbarButton('generateMCode'), 'callbackproperties' );
this.addListeners(handle.listener([h;h2], 'actionPerformed', {@(es,ed) LocalGenerateMCode(this)}));

% Settings Tools Menu
h = handle( menubar.getMenuItem('settings'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalOptimizationSettings(this)}));

% Preferences
h = handle( menubar.getMenuItem('perferences'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) LocalPreferences()}));

% What is Linearization Help
h = handle( menubar.getMenuItem('whatislin'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('whatislin')}));

% Linearizing Models Help
h = handle( menubar.getMenuItem('linmodels'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('linearizing_models')}));

% IO Help
h = handle( menubar.getMenuItem('ios'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('analysis_ios')}));

% Operating Point Spec
h = handle( menubar.getMenuItem('opspec'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('op_points')}));

% Analysis Results
h = handle( menubar.getMenuItem('results'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('analyzing')}));

% Custom Views
h = handle( menubar.getMenuItem('customviews'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('custom_views')}));

% Export and Save
h = handle( menubar.getMenuItem('exportsave'), 'callbackproperties' );
this.addListeners(handle.listener(h, 'actionPerformed', {@(es,ed) scdguihelp('exporting')}));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalPreferences
function LocalPreferences()

preferences('Simulink Control Design')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLinearizationSettings
function LocalOptimizationSettings(this)

dlg = slctrlguis.optionsdlgs.getLinearizationOperatingPointSearchDialog(this);
dlg.setSelectedTab('OperatingPoint')
dlg.show;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGenerateMCode
function LocalGenerateMCode(this)

try
    str = generateMATLABCode(this);
    % Display the mcode
    slctrlguis.util.showGeneratedMATLABCode(str)
catch Ex
    errordlg(ltipack.utStripErrorHeader(Ex.message),'Simulink Control Design');
end