function cm = sl_customization_manager
% SL_CUSTOMIZATION_MANAGER Returns a handle to the Simulink customization manager.
%
% Use the handle to invoke customization manager methods for customizing 
% Simulink menus and dialog boxes. 
%
% Example:
%    cm = sl_customization_manager;
%    cm.showWidgetIdAsToolTip = 1;
%
% For more information, see <a href="matlab: helpview([docroot '/mapfiles/simulink.map'], 'customize_gui')">Customizing the Simulink User Interface</a>.
%
% See also SL_ACTION_SCHEMA, SL_TOGGLE_SCHEMA, SL_CONTAINER_SCHEMA, 
% SL_REFRESH_CUSTOMIZATIONS.


% Copyright 1990-2005 The MathWorks, Inc.

    cm = DAStudio.CustomizationManager;
    